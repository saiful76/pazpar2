/* This file is part of Pazpar2.
   Copyright (C) 2006-2010 Index Data

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

#ifndef PAZPAR2_SESSION_H
#define PAZPAR2_SESSION_H

#include <yaz/comstack.h>
#include <yaz/pquery.h>
#include <yaz/ccl.h>
#include <yaz/yaz-ccl.h>

#include "termlists.h"
#include "reclists.h"
#include "http.h"

struct record;
struct client;


enum pazpar2_error_code {
    PAZPAR2_NO_ERROR = 0,

    PAZPAR2_NO_SESSION,
    PAZPAR2_MISSING_PARAMETER,
    PAZPAR2_MALFORMED_PARAMETER_VALUE,
    PAZPAR2_MALFORMED_PARAMETER_ENCODING,
    PAZPAR2_MALFORMED_SETTING,
    PAZPAR2_HITCOUNTS_FAILED,
    PAZPAR2_RECORD_MISSING,
    PAZPAR2_NO_TARGETS,
    PAZPAR2_CONFIG_TARGET,
    PAZPAR2_RECORD_FAIL,
    PAZPAR2_NOT_IMPLEMENTED,
    PAZPAR2_NO_SERVICE,

    PAZPAR2_LAST_ERROR
};

struct host;
// Represents a (virtual) database on a host
struct database {
    struct host *host;
    char *url;
    char **databases;
    int errors;
    struct zr_explain *explain;
    int num_settings;
    struct setting **settings;
    struct database *next;
};


// Represents a database as viewed from one session, possibly with settings overriden
// for that session
struct session_database
{
    struct database *database;
    int num_settings;
    struct setting **settings;
    normalize_record_t map;
    struct session_database *next;
};

#define SESSION_WATCH_SHOW      0
#define SESSION_WATCH_RECORD    1
#define SESSION_WATCH_SHOW_PREF 2
#define SESSION_WATCH_MAX       2

#define SESSION_MAX_TERMLISTS 10

typedef void (*session_watchfun)(void *data);

struct named_termlist
{
    char *name;
    struct termlist *termlist;
};

struct session_watchentry {
    void *data;
    http_channel_observer_t obs;
    session_watchfun fun;
};

struct client_list;

// End-user session
struct session {
    struct conf_service *service; /* service in use for this session */
    struct session_database *databases;  // All databases, settings overriden
    struct client_list *clients;   // Clients connected for current search
    NMEM session_nmem;  // Nmem for session-permanent storage
    NMEM nmem;          // Nmem for each operation (i.e. search, result set, etc)
    WRBUF wrbuf;        // Wrbuf for scratch(i.e. search)
    int num_termlists;
    struct named_termlist termlists[SESSION_MAX_TERMLISTS];
    struct relevance *relevance;
    struct reclist *reclist;
    struct session_watchentry watchlist[SESSION_WATCH_MAX + 1];
    Odr_int total_hits;
    int total_records;
    int total_merged;
    int number_of_warnings_unknown_elements;
    int number_of_warnings_unknown_metadata;
    normalize_cache_t normalize_cache;
    YAZ_MUTEX session_mutex;
    unsigned session_id;
};

struct statistics {
    int num_clients;
    int num_no_connection;
    int num_connecting;
    int num_working;
    int num_idle;
    int num_failed;
    int num_error;
    Odr_int num_hits;
    int num_records;
};

struct hitsbytarget {
    char *id;
    const char *name;
    Odr_int hits;
    int diagnostic;
    int records;
    const char *state;
    int connected;
    WRBUF settings_xml;
};

struct hitsbytarget *hitsbytarget(struct session *s, int *count, NMEM nmem);
struct session *new_session(NMEM nmem, struct conf_service *service,
                            unsigned session_id);
void destroy_session(struct session *s);
void session_init_databases(struct session *s);
int load_targets(struct session *s, const char *fn);
void statistics(struct session *s, struct statistics *stat);
enum pazpar2_error_code search(struct session *s, const char *query,
                               const char *startrecs, const char *maxrecs,
                               const char *filter, const char **addinfo);
struct record_cluster **show_range_start(struct session *s,
                                         struct reclist_sortparms *sp,
                                         int start,
                                         int *num, int *total, Odr_int *sumhits);
void show_range_stop(struct session *s, struct record_cluster **recs);

struct record_cluster *show_single_start(struct session *s, const char *id,
                                         struct record_cluster **prev_r,
                                         struct record_cluster **next_r);
void show_single_stop(struct session *s, struct record_cluster *rec);
struct termlist_score **termlist(struct session *s, const char *name, int *num);
int session_set_watch(struct session *s, int what, session_watchfun fun, void *data, struct http_channel *c);
int session_active_clients(struct session *s);
int session_is_preferred_clients_ready(struct session *s);
void session_apply_setting(struct session *se, char *dbname, char *setting, char *value);
const char *session_setting_oneval(struct session_database *db, int offset);

int host_getaddrinfo(struct host *host, iochan_man_t iochan_man);

int ingest_record(struct client *cl, const char *rec, int record_no, NMEM nmem);
void session_alert_watch(struct session *s, int what);
void pull_terms(NMEM nmem, struct ccl_rpn_node *n, char **termlist, int *num);

void add_facet(struct session *s, const char *type, const char *value, int count);
void session_log(struct session *s, int level, const char *fmt, ...)
#ifdef __GNUC__
    __attribute__ ((format (printf, 3, 4)))
#endif
    ;
#endif

/*
 * Local variables:
 * c-basic-offset: 4
 * c-file-style: "Stroustrup"
 * indent-tabs-mode: nil
 * End:
 * vim: shiftwidth=4 tabstop=8 expandtab
 */

