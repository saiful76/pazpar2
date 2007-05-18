/* A very simple client that shows a basic usage of the pz2.js
** $Id: example_client.js,v 1.1 2007-05-18 11:36:39 jakub Exp $
*/

// create a parameters array and pass it to the pz2's constructor
// then register the form submit event with the pz2.search function
// autoInit is set to true on default

my_paz = new pz2( { "onshow": my_onshow,
                    "showtime": 500,            //each timer (show, stat, term, bytarget) can be specified this way
                    "onstat": my_onstat,
                    "onterm": my_onterm,
                    "termlist": "subject,author",
                    "onbytarget": my_onbytarget,
                    "onrecord": my_onrecord } );
// some state vars
var curPage = 1;
var recPerPage = 15;
var totalRec = 0;
var curDetRecId = -1;
var curDetRecData = null;

// wait until the DOM is ready
function domReady () 
{ 
    document.search.onsubmit = onFormSubmitEventHandler;
}

// when search button pressed
function onFormSubmitEventHandler() 
{
    my_paz.search(document.search.query.value, recPerPage, 'relevance');
    return false;
}

//
// pz2.js event handlers:
//

function my_onshow(data) {
    totalRec = data.merged;
    
    var body = document.getElementById("body");
    body.innerHTML = "";

    body.innerHTML +='<div>Displaying: ' + data.start + ' to ' + (data.start + data.num) +
                     ' of ' + data.merged + ' (total not merged hits: ' + data.total + ')</div><hr/>';

    body.innerHTML += '<span id="prev" onclick="pagerPrev();" style="cursor: pointer;">Prev</span> <b>|</b> ' 
                + '<span id="next" onclick="pagerNext()" style="cursor: pointer;">Next</span><hr/>';
    
    for (var i = 0; i < data.hits.length; i++) {
        var hit = data.hits[i];
        body.innerHTML += '<div id="rec_' + hit.recid + '" onclick="showDetails(this.id)">'
                        +'<span>' + (i + 1 + recPerPage * ( curPage - 1)) + '. </span>'
                        +'<span style="cursor: pointer;"><b>' + hit["md-title"] +
                        ' </b></span> by <span><i>' + hit["md-author"] + '</i></span></div>';

        if ( hit.recid == curDetRecId ) {
            drawCurDetails();
        }
    }
    
}

function my_onstat(data) {
    var stat = document.getElementById("stat");
    stat.innerHTML = '<span>active clients: ' + data.activeclients + ' </span>' +
                     '<span>hits: ' + data.hits + ' </span>' +
                     '<span>records: ' + data.records + ' </span>' +
                     '<span>clients: ' + data.clients + ' </span>' +
                     '<span>searching: ' + data.searching + '</span>';
}

function my_onterm(data) {
    var termlist = document.getElementById("termlist");
    termlist.innerHTML = "";
    termlist.innerHTML  += "<div><b> --Author </b></div>";
    for (var i = 0; i < data.author.length; i++ ) {
        termlist.innerHTML += '<div><span>' + data.author[i].name + ' </span><span> (' + data.author[i].freq + ')</span></div>';
    }
    termlist.innerHTML += "<hr/>";
    termlist.innerHTML += "<div><b> --Subject </b></div>";
    for (var i = 0; i < data.subject.length; i++ ) {
        termlist.innerHTML += '<div><span>' + data.subject[i].name + ' </span><span> (' + data.subject[i].freq + ')</span></div>';
    }
}

function my_onrecord(data) {
    // in case on_show was faster to redraw element
    var detRecordDiv = document.getElementById('det_'+data.recid);
    if ( detRecordDiv )
        return;

    curDetRecData = data;
    drawCurDetails();
}

function my_onbytarget(data) {
    var targetDiv = document.getElementById("bytarget");
    targetDiv.innerHTML = '<thead><tr><td>ID</td><td>Hits</td><td>Diag</td><td>Rec</td><td>State</td></tr></thead>';
    
    for (var i = 0; i < data.length; i++ ) {
        targetDiv.innerHTML += "<tr><td><b>" + data[i].id +
                               "</b></td><td>" + data[i].hits +
                               "</td><td>" + data[i].diagnostic +
                               "</td><td>" + data[i].records +
                               "</td><td>" + data[i].state + "</td></tr>";
    }
}

// detailed record drawing
function showDetails ( prefixRecId ) {
    var recId = Number(prefixRecId.replace('rec_', ''));
    
    // if the same clicked ignore
    if ( recId == curDetRecId )
        return;
    
    // if different remove the old one 
    var detRecordDiv = document.getElementById('det_'+curDetRecId);
    // lovin DOM!
    if ( detRecordDiv )
            detRecordDiv.parentNode.removeChild(detRecordDiv);

    curDetRecId = recId;

    // request the record
    my_paz.record(recId);
}

function drawCurDetails ()
{
    var data = curDetRecData;
    var recordDiv = document.getElementById('rec_'+data.recid);
    recordDiv.innerHTML += '<div id="det_'+data.recid+'"><table><tr><td><b>Ttle</b></td><td><b>:</b> ' + data["md-title"] +
                            "</td></tr><tr><td><b>Date</b></td><td><b>:</b> " + data["md-date"] +
                            "</td></tr><tr><td><b>Author</b></td><td><b>:</b> " + data["md-author"] +
                            "</td></tr><tr><td><b>Subject</b></td><td><b>:</b> " + data["md-subject"] + 
                            "</td></tr><tr><td><b>Location</b></td><td><b>:</b> " + data["location"][0].name + 
                            "</td></tr></table></div>";
}


// simple paging functions

function pagerNext() {
    if ( totalRec - recPerPage*curPage > 0) {
        my_paz.showNext();
        curPage++;
    }
}

function pagerPrev() {
    if ( my_paz.showPrev() != false )
        curPage--;
}