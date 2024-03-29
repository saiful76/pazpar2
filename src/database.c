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

#if HAVE_CONFIG_H
#include <config.h>
#endif

#include <libxml/parser.h>
#include <libxml/tree.h>
#include <assert.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <yaz/log.h>
#include <yaz/nmem.h>

#include "ppmutex.h"
#include "session.h"
#include "host.h"
#include "pazpar2_config.h"
#include "settings.h"
#include "http.h"
#include "database.h"

#include <sys/types.h>
#if HAVE_SYS_SOCKET_H
#include <sys/socket.h>
#endif
#if HAVE_NETDB_H
#include <netdb.h>
#endif
#if HAVE_NETINET_IN_H
#include <netinet/in.h>
#endif

enum pazpar2_database_criterion_type {
    PAZPAR2_STRING_MATCH,
    PAZPAR2_SUBSTRING_MATCH
};

struct database_criterion_value {
    char *value;
    struct database_criterion_value *next;
};

struct database_criterion {
    char *name;
    enum pazpar2_database_criterion_type type;
    struct database_criterion_value *values;
    struct database_criterion *next;
};


struct database_hosts {
    struct host *hosts;
    YAZ_MUTEX mutex;
};

// Create a new host structure for hostport
static struct host *create_host(const char *hostport, iochan_man_t iochan_man)
{
    struct host *host;

    host = xmalloc(sizeof(struct host));
    host->hostport = xstrdup(hostport);
    host->connections = 0;
    host->ipport = 0;
    host->mutex = 0;

    if (host_getaddrinfo(host, iochan_man))
    {
        xfree(host->hostport);
        xfree(host);
        return 0;
    }
    pazpar2_mutex_create(&host->mutex, "host");

    yaz_cond_create(&host->cond_ready);

    return host;
}

static struct host *find_host(database_hosts_t hosts,
                              const char *hostport, iochan_man_t iochan_man)
{
    struct host *p;
    yaz_mutex_enter(hosts->mutex);
    for (p = hosts->hosts; p; p = p->next)
        if (!strcmp(p->hostport, hostport))
            break;
    if (!p)
    {
        p = create_host(hostport, iochan_man);
        if (p)
        {
            p->next = hosts->hosts;
            hosts->hosts = p;
        }
    }
    yaz_mutex_leave(hosts->mutex);
    return p;
}

int resolve_database(struct conf_service *service, struct database *db)
{
    if (db->host == 0)
    {
        struct host *host;
        char *p;
        char hostport[256];
        strcpy(hostport, db->url);
        if ((p = strchr(hostport, '/')))
            *p = '\0';
        if (!(host = find_host(service->server->database_hosts,
                               hostport, service->server->iochan_man)))
            return -1;
        db->host = host;
    }
    return 0;
}

void resolve_databases(struct conf_service *service)
{
    struct database *db = service->databases;
    for (; db; db = db->next)
        resolve_database(service, db);
}

struct database *new_database(const char *id, NMEM nmem)
{
    struct database *db;
    char hostport[256];
    char *dbname;
    char *db_comment;
    struct setting *idset;

    if (strlen(id) > 255)
        return 0;
    strcpy(hostport, id);
    if ((dbname = strchr(hostport, '/')))
        *(dbname++) = '\0';
    else
        dbname = "";
    db_comment = strchr(dbname, '#');
    if (db_comment)
        *db_comment = '\0';
    db = nmem_malloc(nmem, sizeof(*db));
    memset(db, 0, sizeof(*db));
    db->host = 0;
    db->url = nmem_strdup(nmem, id);
    db->databases = nmem_malloc(nmem, 2 * sizeof(char *));
    db->databases[0] = nmem_strdup(nmem, dbname);
    db->databases[1] = 0;
    db->errors = 0;
    db->explain = 0;

    db->num_settings = PZ_MAX_EOF;
    db->settings = nmem_malloc(nmem, sizeof(struct settings*) * 
                               db->num_settings);
    memset(db->settings, 0, sizeof(struct settings*) * db->num_settings);
    idset = nmem_malloc(nmem, sizeof(*idset));
    idset->precedence = 0;
    idset->name = "pz:id";
    idset->target = idset->value = db->url;
    idset->next = 0;
    db->settings[PZ_ID] = idset;
    db->next = 0;

    return db;
}

static struct database *load_database(const char *id,
                                      struct conf_service *service)
{
    struct database *db;
    struct zr_explain *explain = 0;

    db = new_database(id, service->nmem);
    db->explain = explain;
    db->next = service->databases;
    service->databases = db;

    return db;
}

// Return a database structure by ID. Load and add to list if necessary
// new==1 just means we know it's not in the list
struct database *find_database(const char *id, struct conf_service *service)
{
    struct database *p;
    for (p = service->databases; p; p = p->next)
        if (!strcmp(p->url, id))
            return p;
    return load_database(id, service);
}

// This whole session_grep database thing should be moved elsewhere

int match_zurl(const char *zurl, const char *pattern)
{
    int len;

    if (!strcmp(pattern, "*"))
        return 1;
    else if (!strncmp(pattern, "*/", 2))   // host wildcard.. what the heck is that for?
    {
        char *db = strchr(zurl, '/');
        if (!db)
            return 0;
        if (!strcmp(pattern + 2, db))
            return 1;
        else
            return 0;
    }
    else if (*(pattern + (len = strlen(pattern) - 1)) == '*')  // db wildcard
    {
        if (!strncmp(pattern, zurl, len))
            return 1;
        else
            return 2;
    }
    else if (!strcmp(pattern, zurl))
        return 1;
    else
        return 0;
}

// This will be generalized at some point
static int match_criterion(struct setting **settings,
                           struct conf_service *service, 
                           struct database_criterion *c)
{
    int offset = settings_lookup_offset(service, c->name);
    struct database_criterion_value *v;

    if (offset < 0)
    {
        yaz_log(YLOG_WARN, "Criterion not found: %s", c->name);
        return 0;
    }
    if (!settings[offset])
        return 0;
    for (v = c->values; v; v = v->next)
    {
        if (c->type == PAZPAR2_STRING_MATCH)
        {
            if (offset == PZ_ID)
            {
                if (match_zurl(settings[offset]->value, v->value))
                    break;
            }
            else 
            {
                if (!strcmp(settings[offset]->value, v->value))
                    break;
            }
        }            
        else if (c->type == PAZPAR2_SUBSTRING_MATCH)
        {
            if (strstr(settings[offset]->value, v->value))
                break;
        }
    }
    if (v)
        return 1;
    else
        return 0;
}

// parses crit1=val1,crit2=val2|val3,...
static struct database_criterion *create_database_criterion(NMEM m,
                                                            const char *buf)
{
    struct database_criterion *res = 0;
    char **values;
    int num;
    int i;

    if (!buf || !*buf)
        return 0;
    nmem_strsplit(m, ",", buf,  &values, &num);
    for (i = 0; i < num; i++)
    {
        char **subvalues;
        int subnum;
        int subi;
        struct database_criterion *new = nmem_malloc(m, sizeof(*new));
        char *eq;
        if ((eq = strchr(values[i], '=')))
            new->type = PAZPAR2_STRING_MATCH;
        else if ((eq = strchr(values[i], '~')))
            new->type = PAZPAR2_SUBSTRING_MATCH;
        else
        {
            yaz_log(YLOG_WARN, "Missing equal-sign/tilde in filter");
            return 0;
        }
        *(eq++) = '\0';
        new->name = values[i];
        nmem_strsplit(m, "|", eq, &subvalues, &subnum);
        new->values = 0;
        for (subi = 0; subi < subnum; subi++)
        {
            struct database_criterion_value *newv
                = nmem_malloc(m, sizeof(*newv));
            newv->value = subvalues[subi];
            newv->next = new->values;
            new->values = newv;
        }
        new->next = res;
        res = new;
    }
    return res;
}

static int database_match_criteria(struct setting **settings,
                                   struct conf_service *service,
                                   struct database_criterion *cl)
{
    for (; cl; cl = cl->next)
        if (!match_criterion(settings, service, cl))
            break;
    if (cl) // one of the criteria failed to match -- skip this db
        return 0;
    else
        return 1;
}

// Cycles through databases, calling a handler function on the ones for
// which all criteria matched.
int session_grep_databases(struct session *se, const char *filter,
                           void (*fun)(void *context, struct session_database *db))
{
    struct session_database *p;
    NMEM nmem = nmem_create();
    int i = 0;
    struct database_criterion *cl = create_database_criterion(nmem, filter);

    for (p = se->databases; p; p = p->next)
    {
        if (p->settings && p->settings[PZ_ALLOW] && *p->settings[PZ_ALLOW]->value == '0')
            continue;
        if (!p->settings[PZ_NAME])
            continue;
        if (database_match_criteria(p->settings, se->service, cl))
        {
            (*fun)(se, p);
            i++;
        }
    }
    nmem_destroy(nmem);
    return i;
}

int predef_grep_databases(void *context, struct conf_service *service,
                          void (*fun)(void *context, struct database *db))
{
    struct database *p;
    int i = 0;

    for (p = service->databases; p; p = p->next)
        if (database_match_criteria(p->settings, service, 0))
        {
            (*fun)(context, p);
            i++;
        }
    return i;
}

database_hosts_t database_hosts_create(void)
{
    database_hosts_t p = xmalloc(sizeof(*p));
    p->hosts = 0;
    p->mutex = 0;
    pazpar2_mutex_create(&p->mutex, "database");
    return p;
}

void database_hosts_destroy(database_hosts_t *pp)
{
    if (*pp)
    {
        struct host *p = (*pp)->hosts;
        while (p)
        {
            struct host *p_next = p->next;
            yaz_mutex_destroy(&p->mutex);
            yaz_cond_destroy(&p->cond_ready);
            xfree(p->ipport);
            xfree(p->hostport);
            xfree(p);
            p = p_next;
        }
        yaz_mutex_destroy(&(*pp)->mutex);
        xfree(*pp);
    }
}

/*
 * Local variables:
 * c-basic-offset: 4
 * c-file-style: "Stroustrup"
 * indent-tabs-mode: nil
 * End:
 * vim: shiftwidth=4 tabstop=8 expandtab
 */

