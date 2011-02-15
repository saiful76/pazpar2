/* This file is part of Pazpar2.
   Copyright (C) 2006-2011 Index Data

Pazpar2 is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation; either version 2, or (at your option) any later
version.

Pazpar2 is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

*/

/** \file connection.c
    \brief Z39.50 connection (low-level client)
*/

#if HAVE_CONFIG_H
#include <config.h>
#endif

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#if HAVE_SYS_TIME_H
#include <sys/time.h>
#endif
#if HAVE_UNISTD_H
#include <unistd.h>
#endif

#include <signal.h>
#include <assert.h>

#include <yaz/log.h>
#include <yaz/comstack.h>
#include <yaz/tcpip.h>
#include "connection.h"
#include "session.h"
#include "host.h"
#include "client.h"
#include "settings.h"

/* connection counting (1) , disable connection counting (0) */
#if 0
static YAZ_MUTEX g_mutex = 0;
static int no_connections = 0;

static void connection_use(int delta)
{
    if (!g_mutex)
        yaz_mutex_create(&g_mutex);
    yaz_mutex_enter(g_mutex);
    no_connections += delta;
    yaz_mutex_leave(g_mutex);
    yaz_log(YLOG_LOG, "%s connections=%d", delta > 0 ? "INC" : "DEC",
            no_connections);
}
#else
#define connection_use(x)
#endif


/** \brief Represents a physical, reusable  connection to a remote Z39.50 host
 */
struct connection {
    IOCHAN iochan;
    ZOOM_connection link;
    struct host *host;
    struct client *client;
    char *zproxy;
    enum {
        Conn_Resolving,
        Conn_Connecting,
        Conn_Open,
        Conn_Dead
    } state;
    int operation_timeout;
    int session_timeout;
    struct connection *next; // next for same host or next in free list
};

static int connection_connect(struct connection *con, iochan_man_t iochan_man);

static int connection_is_idle(struct connection *co)
{
    ZOOM_connection link = co->link;
    int event;

    if (co->state != Conn_Open || !link)
        return 0;

    if (!ZOOM_connection_is_idle(link))
        return 0;
    event = ZOOM_connection_peek_event(link);
    if (event == ZOOM_EVENT_NONE)
        return 1;
    else
        return 0;
}

ZOOM_connection connection_get_link(struct connection *co)
{
    return co->link;
}

static void remove_connection_from_host(struct connection *con)
{
    struct connection **conp = &con->host->connections;
    assert(con);
    while (*conp)
    {
        if (*conp == con)
        {
            *conp = (*conp)->next;
            break;
        }
        conp = &(*conp)->next;
    }
    yaz_cond_broadcast(con->host->cond_ready);
}

// Close connection and recycle structure
static void connection_destroy(struct connection *co)
{
    if (co->link)
    {
        ZOOM_connection_destroy(co->link);
        iochan_destroy(co->iochan);
    }
    yaz_log(YLOG_DEBUG, "%p Connection destroy %s", co, co->host->hostport);

    if (co->client)
    {
        client_disconnect(co->client);
    }

    xfree(co->zproxy);
    xfree(co);
    connection_use(-1);
}

// Creates a new connection for client, associated with the host of 
// client's database
static struct connection *connection_create(struct client *cl,
                                            int operation_timeout,
                                            int session_timeout,
                                            iochan_man_t iochan_man)
{
    struct connection *co;
    struct host *host = client_get_host(cl);

    co = xmalloc(sizeof(*co));
    co->host = host;

    co->client = cl;
    co->zproxy = 0;
    client_set_connection(cl, co);
    co->link = 0;
    co->state = Conn_Resolving;
    co->operation_timeout = operation_timeout;
    co->session_timeout = session_timeout;
    if (host->ipport)
        connection_connect(co, iochan_man);

    yaz_mutex_enter(host->mutex);
    co->next = co->host->connections;
    co->host->connections = co;
    yaz_mutex_leave(host->mutex);

    connection_use(1);
    return co;
}

static void non_block_events(struct connection *co)
{
    int got_records = 0;
    IOCHAN iochan = co->iochan;
    ZOOM_connection link = co->link;
    while (1)
    {
        struct client *cl = co->client;
        int ev;
        int r = ZOOM_event_nonblock(1, &link);
        if (!r)
            break;
        if (!cl)
            continue;
        ev = ZOOM_connection_last_event(link);
        
#if 1
        yaz_log(YLOG_DEBUG, "%p Connection ZOOM_EVENT_%s", co, ZOOM_get_event_str(ev));
#endif
        switch (ev) 
        {
        case ZOOM_EVENT_END:
            {
                const char *error, *addinfo;
                int err;
                if ((err = ZOOM_connection_error(link, &error, &addinfo)))
                {
                    yaz_log(YLOG_LOG, "Error %s from %s",
                            error, client_get_url(cl));
                    client_set_diagnostic(cl, err);
                    client_set_state(cl, Client_Error);
                }
                else
                {
                    iochan_settimeout(iochan, co->session_timeout);
                    client_set_state(cl, Client_Idle);
                }
                yaz_cond_broadcast(co->host->cond_ready);
            }
            break;
        case ZOOM_EVENT_SEND_DATA:
            break;
        case ZOOM_EVENT_RECV_DATA:
            break;
        case ZOOM_EVENT_UNKNOWN:
            break;
        case ZOOM_EVENT_SEND_APDU:
            client_set_state(co->client, Client_Working);
            iochan_settimeout(iochan, co->operation_timeout);
            break;
        case ZOOM_EVENT_RECV_APDU:
            break;
        case ZOOM_EVENT_CONNECT:
            yaz_log(YLOG_LOG, "Connected to %s", client_get_url(cl));
            co->state = Conn_Open;
            break;
        case ZOOM_EVENT_RECV_SEARCH:
            client_search_response(cl);
            break;
        case ZOOM_EVENT_RECV_RECORD:
            client_record_response(cl);
            got_records = 1;
            break;
        default:
            yaz_log(YLOG_LOG, "Unhandled event (%d) from %s",
                    ev, client_get_url(cl));
        }
    }
    if (got_records)
    {
        struct client *cl = co->client;
        if (cl)
        {
            client_check_preferred_watch(cl);
            client_got_records(cl);
        }
    }
}

void connection_continue(struct connection *co)
{
    int r = ZOOM_connection_exec_task(co->link);
    if (!r)
        yaz_log(YLOG_WARN, "No task was executed for connection");
    iochan_setflags(co->iochan, ZOOM_connection_get_mask(co->link));
    iochan_setfd(co->iochan, ZOOM_connection_get_socket(co->link));
}

static void connection_handler(IOCHAN iochan, int event)
{
    struct connection *co = iochan_getdata(iochan);
    struct client *cl;
    struct host *host = co->host;

    yaz_mutex_enter(host->mutex);
    cl = co->client;
    if (!cl) 
    {
        /* no client associated with it.. We are probably getting
           a closed connection from the target.. Or, perhaps, an unexpected
           package.. We will just close the connection */
        yaz_log(YLOG_LOG, "timeout connection %p event=%d", co, event);
        remove_connection_from_host(co);
        yaz_mutex_leave(host->mutex);
        connection_destroy(co);
    }
    else if (event & EVENT_TIMEOUT)
    {
        if (co->state == Conn_Connecting)
        {
            yaz_log(YLOG_WARN, "%p connect timeout %s", co, client_get_url(cl));

            client_set_state(cl, Client_Error);
            remove_connection_from_host(co);
            yaz_mutex_leave(host->mutex);
            connection_destroy(co);
        }
        else
        {
            yaz_log(YLOG_LOG,  "%p Connection idle timeout %s", co, client_get_url(cl));
            remove_connection_from_host(co);
            yaz_mutex_leave(host->mutex);
            connection_destroy(co);
        }
    }
    else
    {
        yaz_mutex_leave(host->mutex);

        client_lock(cl);
        non_block_events(co);

        ZOOM_connection_fire_event_socket(co->link, event);
        
        non_block_events(co);
        client_unlock(cl);

        if (co->link)
        {
            iochan_setflags(iochan, ZOOM_connection_get_mask(co->link));
            iochan_setfd(iochan, ZOOM_connection_get_socket(co->link));
        }
    }
}


// Disassociate connection from client
static void connection_release(struct connection *co)
{
    struct client *cl = co->client;

    if (!cl)
        return;
    client_set_connection(cl, 0);
    co->client = 0;
}

void connect_resolver_host(struct host *host, iochan_man_t iochan_man)
{
    struct connection *con;

start:
    yaz_mutex_enter(host->mutex);
    con = host->connections;
    while (con)
    {
        if (con->state == Conn_Resolving)
        {
            if (!host->ipport) /* unresolved */
            {
                remove_connection_from_host(con);
                yaz_mutex_leave(host->mutex);
                connection_destroy(con);
                goto start;
                /* start all over .. at some point it will be NULL */
            }
            else if (!con->client)
            {
                remove_connection_from_host(con);
                yaz_mutex_leave(host->mutex);
                connection_destroy(con);
                /* start all over .. at some point it will be NULL */
                goto start;
            }
            else
            {
                yaz_mutex_leave(host->mutex);
                connection_connect(con, iochan_man);
                client_start_search(con->client);
                goto start;
            }
        }
        else
        {
            yaz_log(YLOG_LOG, "connect_resolver_host: state=%d", con->state);
            con = con->next;
        }
    }
    yaz_mutex_leave(host->mutex);
}

static struct host *connection_get_host(struct connection *con)
{
    return con->host;
}

static int connection_connect(struct connection *con, iochan_man_t iochan_man)
{
    ZOOM_connection link = 0;
    struct host *host = connection_get_host(con);
    ZOOM_options zoptions = ZOOM_options_create();
    const char *auth;
    const char *charset;
    const char *sru;
    const char *sru_version = 0;

    struct session_database *sdb = client_get_database(con->client);
    const char *zproxy = session_setting_oneval(sdb, PZ_ZPROXY);
    const char *apdulog = session_setting_oneval(sdb, PZ_APDULOG);

    assert(host->ipport);
    assert(con);

    ZOOM_options_set(zoptions, "async", "1");
    ZOOM_options_set(zoptions, "implementationName", PACKAGE_NAME);
    ZOOM_options_set(zoptions, "implementationVersion", VERSION);
	
    if ((charset = session_setting_oneval(sdb, PZ_NEGOTIATION_CHARSET)))
        ZOOM_options_set(zoptions, "charset", charset);
    
    if (zproxy && *zproxy)
    {
        con->zproxy = xstrdup(zproxy);
        ZOOM_options_set(zoptions, "proxy", zproxy);
    }
    if (apdulog && *apdulog)
        ZOOM_options_set(zoptions, "apdulog", apdulog);

    if ((auth = session_setting_oneval(sdb, PZ_AUTHENTICATION)))
        ZOOM_options_set(zoptions, "user", auth);
    if ((sru = session_setting_oneval(sdb, PZ_SRU)) && *sru)
        ZOOM_options_set(zoptions, "sru", sru);
    if ((sru_version = session_setting_oneval(sdb, PZ_SRU_VERSION)) 
        && *sru_version)
        ZOOM_options_set(zoptions, "sru_version", sru_version);

    if (!(link = ZOOM_connection_create(zoptions)))
    {
        yaz_log(YLOG_FATAL|YLOG_ERRNO, "Failed to create ZOOM Connection");
        ZOOM_options_destroy(zoptions);
        return -1;
    }

    if (sru && *sru)
    {
        char http_hostport[512];
        strcpy(http_hostport, "http://");
        strcat(http_hostport, host->hostport);
        ZOOM_connection_connect(link, http_hostport, 0);
    }
    else if (zproxy && *zproxy)
        ZOOM_connection_connect(link, host->hostport, 0);        
    else
        ZOOM_connection_connect(link, host->ipport, 0);
    
    con->link = link;
    con->iochan = iochan_create(-1, connection_handler, 0, "connection_socket");
    con->state = Conn_Connecting;
    iochan_settimeout(con->iochan, con->operation_timeout);
    iochan_setdata(con->iochan, con);
    iochan_add(iochan_man, con->iochan);

    /* this fragment is bad DRY: from client_prep_connection */
    client_set_state(con->client, Client_Connecting);
    ZOOM_options_destroy(zoptions);
    return 0;
}

// Ensure that client has a connection associated
int client_prep_connection(struct client *cl,
                           int operation_timeout, int session_timeout,
                           iochan_man_t iochan_man,
                           const struct timeval *abstime)
{
    struct connection *co;
    struct host *host = client_get_host(cl);
    struct session_database *sdb = client_get_database(cl);
    const char *zproxy = session_setting_oneval(sdb, PZ_ZPROXY);

    if (zproxy && zproxy[0] == '\0')
        zproxy = 0;

    if (!host)
        return 0;

    co = client_get_connection(cl);

    yaz_log(YLOG_DEBUG, "Client prep %s", client_get_url(cl));

    if (!co)
    {
        int max_connections = 0;
        int reuse_connections = 1;
        const char *v = session_setting_oneval(client_get_database(cl),
                                               PZ_MAX_CONNECTIONS);
        if (v && *v)
            max_connections = atoi(v);

        v = session_setting_oneval(client_get_database(cl),
                PZ_REUSE_CONNECTIONS);
        if (v && *v)
            reuse_connections = atoi(v);

        // See if someone else has an idle connection
        // We should look at timestamps here to select the longest-idle connection
        yaz_mutex_enter(host->mutex);
        while (1)
        {
            int num_connections = 0;
            for (co = host->connections; co; co = co->next)
                num_connections++;
            if (reuse_connections) {
                for (co = host->connections; co; co = co->next)
                {
                    if (connection_is_idle(co) &&
                        (!co->client || client_get_state(co->client) == Client_Idle) &&
                        !strcmp(ZOOM_connection_option_get(co->link, "user"),
                                session_setting_oneval(client_get_database(cl),
                                                       PZ_AUTHENTICATION)))
                    {
                        if (zproxy == 0 && co->zproxy == 0)
                            break;
                        if (zproxy && co->zproxy && !strcmp(zproxy, co->zproxy))
                            break;
                    }
                }
                if (co)
                {
                    yaz_log(YLOG_LOG, "num_connections = %d (reusing)", num_connections);
                    break;
                }
            }
            if (max_connections <= 0 || num_connections < max_connections)
            {
                yaz_log(YLOG_LOG, "num_connections = %d (new); max = %d",
                        num_connections, max_connections);
                break;
            }
            yaz_log(YLOG_LOG, "num_connections = %d (waiting) max = %d",
                    num_connections, max_connections);
            if (yaz_cond_wait(host->cond_ready, host->mutex, abstime))
            {
                yaz_log(YLOG_LOG, "out of connections %s", client_get_url(cl));
                client_set_state(cl, Client_Error);
                yaz_mutex_leave(host->mutex);
                return 0;
            }
        }
        if (co)
        {
            yaz_log(YLOG_LOG,  "%p Connection reuse. state: %d", co, co->state);
            connection_release(co);
            client_set_connection(cl, co);
            co->client = cl;
            /* ensure that connection is only assigned to this client
               by marking the client non Idle */
            client_set_state(cl, Client_Working);
            yaz_mutex_leave(host->mutex);
            co->operation_timeout = operation_timeout;
            co->session_timeout = session_timeout;
            /* tells ZOOM to reconnect if necessary. Disabled becuase
               the ZOOM_connection_connect flushes the task queue */
            ZOOM_connection_connect(co->link, 0, 0);
        }
        else
        {
            yaz_mutex_leave(host->mutex);
            co = connection_create(cl, operation_timeout, session_timeout,
                                   iochan_man);
        }
    }

    if (co && co->link)
        return 1;
    else
        return 0;
}

/*
 * Local variables:
 * c-basic-offset: 4
 * c-file-style: "Stroustrup"
 * indent-tabs-mode: nil
 * End:
 * vim: shiftwidth=4 tabstop=8 expandtab
 */

