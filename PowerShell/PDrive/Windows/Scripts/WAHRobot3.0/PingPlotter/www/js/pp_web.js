/* The code in this library is copyrighted by Nessoft, LLC

 (C) 2004, 2015 Nessoft LLC.  All rights reserved.
 http://www.nessoft.com

 The code in this library is for use only with the Nessoft products,
 "PingPlotter" and "PingPlotter Pro".

 You cannot redistribute this code in any way.  Users with licenses
 for the products listed above have the right to use this library,
 and purchasing a license also entitles those users to modify this
 library for use with the product.  Modifications may not be
 be distributed without prior consent of Nessoft, LLC.  For
 questions about this, please contact us.
 */

const GOOD_BG_COLOR = "#e0f1d6";
const WARN_BG_COLOR = "#ffedce";
const BAD_BG_COLOR = "#fed2ce";

(function ($) {
  $.fn.setHTMLIfDifferent = function (newHTML) {
    if (this.html() != newHTML) {
      this.html(newHTML);
    }
    return this;
  }
})(jQuery);

var refreshCount = 0;
if (typeof initialSampleNum != "undefined") {
  refreshCount = initialSampleNum;
}
if (typeof curTargetID == "undefined") {
  var curTargetID = "";
}
if (typeof IsSummary == "undefined") {
  var IsSummary = false;
}
if (typeof settingsFilter == "undefined") {
  var settingsFilter = "";
}
var traceGraphRequest = null;
var numSummarySpots = 0;
var numHop = -1;
var prevTargetID = null;
var lastStatsXML = null;
var columnDefinition = null;
var jg;
var splitPosX;
var curMovingSplitter;
var curSizingColNum;
var routeInfo = [];
var visibleTimeGraphs = [];
var targetFields;
var graphWidth = 0;
var timeGraphHeight = 85;
var refreshInterval;
var eligibleTimeGraphTargets = 0;
var visibleTimeGraphTargets = 0;
var summaryList = {};

var isIphone = ("ontouchend" in document);

// Constants for column types
var ctHop = 0, ctErr = 1, ctPacketLoss = 2, ctIP = 3, ctDNSName = 4, ctAvgTime = 5, ctMinTime = 6, ctMaxTime = 7, ctCurTime = 8, ctGraph = 9, ctUser = 10;
var HeightSetter = null;
var refreshTimerID;
var n = 1.1;
var decimalPointChar = '.';
try {
  decimalPointChar = n.toLocaleString().substring(1, 2);
} catch (err) {
  // Ignore this, if we don't have toLocaleString...
}

get_associated_array("visibleTimeGraphs-" + curTargetID, visibleTimeGraphs);

// Refresh interval setting is shared between all target graphs, although
// the summary is a different configuration.
refreshInterval = Number(get_cookie("refreshInterval-" + (IsSummary ? "SUM" : "TARGET")));
if (refreshInterval == 0) {
  if (IsSummary) {
    refreshInterval = 10000;  // Default to 10 seconds, since we have no "Auto"
  } else {
    refreshInterval = -2;
  }
}  // Set it up to "auto" by default.


// IE and Mozilla have different kinds of error objects.  This "normalizes" so we
// can get a description in both.
function errorDescription(e) {
  var errorMessage = "";
  if ((e) && (e.name)) {
    errorMessage = e.name + ": ";
  }
  if ((e) && (e.message)) {
    errorMessage = errorMessage + e.message;
  } else if ((e) && (e.description)) {
    errorMessage = errorMessage + e.description;
  } else {
    errorMessage = errorMessage + e;
  }
  if ((e) && (e.fileName)) {
    errorMessage = errorMessage + ", file: " + e.fileName;
  }
  if ((e) && (e.lineNumber)) {
    errorMessage = errorMessage + ", line: " + e.lineNumber;
  }
  if ((e) && (e.stack)) {
    errorMessage = errorMessage + "<br />Stack Trace:<br />";
  }
  return errorMessage.replace(/\n/g, "<br />");
}

function escapeHTML(input) {
  // Escape >, <, & and put a break at any > < boundary (so that wordwrap works).
  return input.replace(/><(?!\/)/g, "> <").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
}

function newImage(arg) {
  if (document.images) {
    var rslt = new Image();
    rslt.src = arg;
    return rslt;
  }
}

// Get the target control from an event in a browser independant way.
function eventTarget(evt) {
  if (window.event && window.event.srcElement)
    return window.event.srcElement;
  else if (evt && evt.target)
    return evt.target;
  else
    return undefined;
}

// Normalize the event's mouse location for different browsers
function fixEvent(e) {
  if (typeof e == 'undefined') e = window.event;
  if (typeof e.layerX == 'undefined') e.layerX = e.offsetX;
  if (typeof e.layerY == 'undefined') e.layerY = e.offsetY;
  return e;
}

// Add an event to an object
function addEvent(obj, evType, fn, useCapture) {
  if (obj.addEventListener) {
    obj.addEventListener(evType, fn, useCapture);
    return true;
  } else if (obj.attachEvent) {
    var r = obj.attachEvent('on' + evType, fn);
    return r;
  } else {
    obj['on' + evType] = fn;
  }
}

// Unhook an event
function removeEvent(obj, evType, fn, useCapture) {
  if (obj.removeEventListener) {
    obj.removeEventListener(evType, fn, useCapture);
    return true;
  } else if (obj.detachEvent) {
    var r = obj.detachEvent('on' + evType, fn);
    return r;
  } else {
    obj['on' + evType] = "";
  }
}

// When the script loads, hook to the "load" event.  This
// will intialize our event handlers and such on the page.
$(document).ready(function () {
  initImageLoad();
});

// Do any page initialization stuff.  Note that the page
// is already loaded here.
function initImageLoad() {

  // Get the initial page width, even before the page loads.
  try {
    var InitialWidth = get_cookie("totalwidth-" + (IsSummary ? "SUM" : "TARGET"));
    if (InitialWidth > 100) {
//      document.getElementById("mainpage").style.width = InitialWidth + "px";
    }
  } catch (e) {
  }
  refreshContent();

  $("#btnChangeSettings").hide();
  $("#graphimage").hide();
  $("#tracegraph").show();
  $(document).mousemove(function (e) {
    move_col_drag(e);
  });
  $(document).mouseup(function (e) {
    stop_col_drag(e);
  });

  $('<ul id="menu" class="jeegoocontext cm_default">')
    .appendTo("body").append("<li>");
  $("#tracegraphbody").jeegoocontext('menu', {
    widthOverflowOffset: 0,
    heightOverflowOffset: 1,
    submenuLeftOffset: -4,
    submenuTopOffset: -5,
    onSelect: function(e, context) {
      onGraphContextPicked(e, context, $(this));
    },
    onShow: function(e, context){
      onGraphContextShow(e, context);
    }
  })
//  $("#tracegraphbody").bind("contextmenu", function (e, options) {
//    alert($(e.target).html());
////    graphrightclick(e);
//  })
    .dblclick(function (e) {
      first_col_double_click(e);
    });
  // We want to grab the escape and enter keys when we're in our controls
  // so enter
  $(document).keydown(function (e) {
    editControlKeyDown($(e.target), e);
  });

  // Input highlight on all input / selects.
  $("input,select").focus(function () {
    origValue = this.value;
  }).blur(function () {
    origValue = "";
  });

  $("#editTraceCount,#editSamplesToInclude,#selectTraceInterval,#selectSummaryFocus,#selectSettingsName,#selectTimeGraphTime")
    .change(function (e) {
      inputControlChange($(this), e);
    });

  // Double-click the error hides it (or single on the iPhone)
  if (isIphone) {
    $("#ajaxerror").click(function () {
      $("#ajaxerror").hide().html("");
    });
  } else {
    $("#ajaxerror").dblclick(function () {
      $("#ajaxerror").hide().html("");
    });
  }

  // Set up the active buttons
  $("#btnResume").click(function () {
    $(this).hide();
    refreshContent( {formaction: "Resume Trace"}, true);
    return false;
  });

  $("#btnStop").click(function () {
    $(this).hide();
    refreshContent( {formaction: "Stop Trace"}, true);
    return false;
  });

  $("#btnClose").click(function () {
    $(this).hide();
    refreshContent( {formaction: "Close"}, true);
    return false;
  });

  $("#btnReset").click(function () {
    $(this).hide();
    refreshCount = 0; // Let's do a few fast refreshes at the start here.
    refreshContent( {formaction: "Reset Trace"}, true);
    return false;
  });

  $("#commandouter .actionlinks").addTouch();

  $("#newtargetbtn").click(function () {
    if (traceGraphRequest) {
      traceGraphRequest.abort();
      traceGraphRequest = null;
    }
    try {
      refreshCount = 0;
      if ($("#targetinput").val() > "") {
        $(this).prop("disabled",true);
        $(this).setHTMLIfDifferent(" ... adding ... ");
        traceGraphRequest = $.ajax({
          url: "cmd.asp",
          data: {
            'ID': 'NEWTARGET',
            'target': $("#targetinput").val(),
            'targetstats': 1,
            'alltargets': 1,
            'columns': 1,
            async: false,
            'TraceCount': $("#editTraceCount").val(),
            'Interval': $("#selectTraceInterval").val(),
            'SamplesToInclude': $("#editSamplesToInclude").val(),
            'SettingsName': (settingsFilter > "") ? settingsFilter : $("#selectSettingsName").val() // If we have a settings filter on, only create new targets with that setting.
          },
          cache: false,
          type: "POST",
          datatype: "xml",
          success: function (data, textStatus, jqXHR) {
            $("#newtargetbtn").setHTMLIfDifferent("Trace New Target").prop("disabled",false);
            ajaxGotDataSuccess(data, textStatus, jqXHR);
            $("#targetinput").val('');
          },
          error: function (data, textStatus, jqXHR) {
            $("#newtargetbtn").setHTMLIfDifferent("Trace New Target").prop("disabled",false);
            ajaxError(data, textStatus, jqXHR);
          }
        });
      }
    } catch (e) {
      $("#newtargetbtn").setHTMLIfDifferent("Trace New Target").prop("disabled",false);
      displayError("Error opening new target: " + e.message);
    }
    return false;
  });

  $("#viewsummary").click(function () {
      curTargetID = "Summary";
      refreshContent({}, true);
      return false;
    }
  );

  $("#btnRenameSummary").click(function () {
    var newSummaryName = prompt("Rename this summary to:", targetFields["SummaryName"]);
    if ((newSummaryName != null) && (newSummaryName > "")) {
      refreshContent({cmd: "renamesummary", name: newSummaryName} );
    }
    return false;
  });

  $("#btnCloseSummary").click(function () {
    refreshContent({cmd: "closesummary"});
    return false;
  });
  updateRefreshIntervalDisplay();
}

function formatNumDigits(plnum, digits) {
  var numFmt = parseFloat(plnum.replace(",", ".")).toFixed(digits);
  if (decimalPointChar != '.') {
    numFmt = numFmt.replace('.', decimalPointChar);
  }
  return numFmt;
}


// Convert the XML record to an array.  This makes it easier to access and can
// also "normalize" the different browser versions if we find problems.
function RecordToArray(InRecord) {

  var curChild;
  var ary = [];

  if (InRecord) {
    curChild = InRecord.firstChild;
  }

  while (curChild) {
    if (curChild.firstChild) {
      ary[curChild.nodeName] = curChild.firstChild.nodeValue
    } else {
      ary[curChild.nodeName] = undefined;
    }
    curChild = curChild.nextSibling;
  }
  return ary;
}

var emptyPathTargetID = "";

$.address.externalChange(function (event) {
  if (event.pathNames[0] > "") {
    curTargetID = event.pathNames[0];
    refreshContent({}, false);
  } else {
    if ((emptyPathTargetID > "") && (emptyPathTargetID != curTargetID)) {
      curTargetID = emptyPathTargetID;
      refreshContent({}, false);
    } else if ((emptyPathTargetID == "") && (curTargetID > "")) {
      // If no target is specified, save which target that is so we can go there on a "back".
      emptyPathTargetID = curTargetID;
    }
  }
});

function refreshContent(additionalParams, waitForCompletion) {

  additionalParams = typeof additionalParams !== 'undefined' ?  additionalParams : {};
  waitForCompletion = typeof waitForCompletion !== 'undefined' ?  waitForCompletion : false;

  refreshCount++;

  if (refreshTimerID) {
    clearTimeout(refreshTimerID);
    refreshTimerID = null;
  }

  var doAsync = true;
  if (waitForCompletion) {
    if (traceGraphRequest) {
      traceGraphRequest.abort();
      traceGraphRequest = null;
    }
    doAsync = false;
  }

  // Kick off the asynchronous request for update
  var NeededData = additionalParams;
  NeededData["targetstats"] = 1;
  if ($("#summarylist").length > 0) {
    NeededData["summaries"] = 1;
  }
  if ((!columnDefinition) ||
      // If the new target is a different type of graph, get the columns (switching between summary and non-summary).
      (((typeof targetFields != "undefined") && (targetFields["UniqueID"].substr(0,4) != curTargetID.substr(0,4))))) {
    NeededData["columns"] = 1;
  }
  if ((waitForCompletion) && (curTargetID != $.address.pathNames(0))) {
    $.address.value(curTargetID);
  }

  if (settingsFilter > "") {
    NeededData["SettingsFilter"] = settingsFilter;
  }

  NeededData["ID"] = curTargetID;

  traceGraphRequest = $.ajax({
    url: "cmd.asp",
    data: NeededData,
    type: "POST",
    cache: false,
    datatype: "xml",
    async: doAsync,
    timeout: 15000,
    success: function (data, textStatus, jqXHR) {
      ajaxGotDataSuccess(data, textStatus, jqXHR);
    },
    error: function (data, textStatus, jqXHR) {
      ajaxError(data, textStatus, jqXHR);
    }
  });

  if (waitForCompletion) {
    traceGraphRequest = null;
  } // For synchronous, we're ready to go already...
}

function ajaxError(data, textStatus, ajaxResponse) {
  if ((typeof(ajaxResponse) == 'object') && (data.readyState == 4)) {
    try {
      if (textStatus == "timeout") {
        throw "Timeout";
      } else if (textStatus == "error") {
        if (!(data.status) || // Safari (no testing done) returns no status
          (data.status == 12029) || (data.status == 12030) || (data.status == 12031) || // Internet explorer
          (data.status == 0)) { // Opera errors
          throw "Status " + data.status + " - web browser probably couldn't communicate with web server.";
        } else if (data.status == 12152) {
          throw "Status " + data.status + " - server closed connection.  Is server shutting down or overloaded?";
        } else if (data.status == 12002) {
          throw "Status " + data.status + " - server timed out.";
        } else {
          throw("Unexpected result status: " + data.status + "<br />" + escapeHTML(ajaxResponse.responseText));
        }
      }
    }
    catch (e) {
      // Firefox raises an exception.
      if (e.name && (e.name.toUpperCase() == "NS_ERROR_NOT_AVAILABLE")) {
        // It's a Firefox-specific error
        displayError("Error communicating with PingPlotter Pro.<br />" + "Web browser probably couldn't communicate with web server.<br /><br /><font size=\"-3\">" + errorDescription(e) + "</font>");
      } else {
        displayError("Error communicating with PingPlotter Pro.<br />" + errorDescription(e));
      }
    }
    updateRefreshIntervalDisplay();
    traceGraphRequest = null;  // Clear it so we can re-request.
  }
  else if ((typeof(data) == "object") && (data.responseText)) {
    displayError(data.responseText);
  } else if ((typeof(ajaxResponse) == "string") && (ajaxResponse != "abort")) {
    displayError(ajaxResponse);
  }
}

function ajaxGotDataSuccess(data, textStatus, ajaxResponse) {
  if ((typeof(ajaxResponse) == 'object') && (ajaxResponse.readyState == 4)) {
    try {
      if (ajaxResponse.status == 200) {
        if (!ajaxResponse.responseXML) {
          throw(ajaxResponse.responseText);
        }
        // Iterate the children until one is found with <PingPlotter> root.
        lastStatsXML = ajaxResponse.responseXML.firstChild;
        while ((lastStatsXML) && (lastStatsXML.nodeName != "PingPlotter")) {
          lastStatsXML = lastStatsXML.nextSibling;
        }
        if (!lastStatsXML) {
          throw("&lt;PingPlotter&gt; portion of Ajax XML not found.<br />" + ajaxResponse.responseText);
        }
        try {
          updateTraceGraph(lastStatsXML);
          updateSummaryList(lastStatsXML);
          updateErrorDisplay(lastStatsXML);
        }
        catch (e) {
          displayError("Error loading trace graph data.<br />" + errorDescription(e));
        }
        lastStatsXML = null;
        // If it's running, queue up for the next update
        if ((targetFields) && ((targetFields["IsRunning"] != 0) || IsSummary)) {
          if ((refreshCount < 5) && (!IsSummary)) {
            clearTimeout(refreshTimerID);
            refreshTimerID = setTimeout("refreshContent()", 1500);
          } else {
            if (refreshInterval > 1000) {
              clearTimeout(refreshTimerID);
              refreshTimerID = setTimeout("refreshContent()", refreshInterval);
            } else {
              clearTimeout(refreshTimerID);
              // Is it set to "Auto" (or matching the trace interval)?
              if (refreshInterval == -2) {
                if (curTraceInterval > 1000) {
                  refreshTimerID = setTimeout("refreshContent()", curTraceInterval);
                } else {
                  refreshTimerID = setTimeout("refreshContent()", 1500);
                }
              } else if (refreshInterval == -1) {
                // Don't refresh at all!
              } else {
                refreshTimerID = setTimeout("refreshContent()", 1500);
              }
            }
          }
        }
      } else {
        throw("Unexpected result status: " + ajaxResponse.status + "<br />" + escapeHTML(ajaxResponse.responseText));
      }
    }
    catch (e) {
      // Firefox raises an exception.
      if (e.name && (e.name.toUpperCase() == "NS_ERROR_NOT_AVAILABLE")) {
        // It's a Firefox-specific error
        displayError("Error loading trace graph data.<br />" + "Web browser probably couldn't communicate with web server.<br /><br /><font size=\"-3\">" + errorDescription(e) + "</font>");
      } else {
        displayError("Error loading trace graph data.<br />" + errorDescription(e));
      }
    }
    updateRefreshIntervalDisplay();
    traceGraphRequest = null;  // Clear it so we can re-request.
  }
}

function updateErrorDisplay(targetListXML) {
  var curNode = targetListXML.firstChild;
  var errors;

  while (curNode) {
    if (curNode.nodeName == "errors") {
      errors = curNode;
      break;  // Don't need to look any further.
    }
    curNode = curNode.nextSibling;
  }

  if (errors) {
    for (var i = 0; i < curNode.childNodes.length; i++) {
      displayError("Error: " + curNode.childNodes.item(i).nodeValue);
    }
  }

}

function updateSummaryList(targetListXML) {

  var curNode = targetListXML.firstChild;
  var summaries;
  // Get the XML summaries node.
  while (curNode) {
    if (curNode.nodeName == "summaries") {
      summaries = curNode;
      break;  // Don't need to look any further.
    }
    curNode = curNode.nextSibling;
  }

  // Does the summary list exist?  (Single-target graphs don't have the summary list)
  if (!(summaries === undefined) && $("#summarylist").length) {

    // OK, let's see if we need to change the count of "containers" for the trace stuff.
    if ((summaries.childNodes.length != numSummarySpots)) {
      // Build up the containers - don't need the contents yet, though...
      var summaryhtml = "";
      for (var i = 0; i < summaries.childNodes.length; i++) {
        summaryhtml = summaryhtml + "<div id=\"summarylistname" + i + "\" class=\"summarylistname\"></div>" +
        "&nbsp;&nbsp;<span class=\"summarylistdetails\" id=\"summarylistdetails" + i + "\"></span><br />\n";
      }
      $("#summarylist").html(summaryhtml);
      numSummarySpots = summaries.childNodes.length;


      $(".summarylistname").click(function () {
        curTargetID = $(this).find("A").attr("href").split("=")[1];
        refreshContent({}, true);
        return false;
      });
    }

    var CurArray;
    summaryList = [];

    // Iterate all the targets and fill in the display values
    for (var summaryloop = 0; summaryloop < summaries.childNodes.length; summaryloop++) {
      CurArray = RecordToArray(summaries.childNodes.item(summaryloop));
      summaryList.push(CurArray);
      $("#summarylistname" + summaryloop).setHTMLIfDifferent("<a href=\"?ID=" + CurArray["UniqueID"] + "\">" + CurArray["SummaryName"] + "</a>");
      $("#summarylistdetails" + summaryloop).setHTMLIfDifferent(CurArray["TargetCount"] + " Targets");
    }
  }
}

function updateColWidths() {
  var widthDiff;
  var curWidth;
  var offWidth;
  var newWidth;
  var ColumnDef;
  var columnloop;
  var lastSplitter;
  var graphColumn;
  var lgraphWidth = 0;

  for (columnloop = 0; columnloop < columnDefinition.length; columnloop++) {
    ColumnDef = columnDefinition[columnloop];
    if (ColumnDef["Visible"] != 0) {

      graphColumn = document.getElementById("Graph_Col" + columnloop);
      if (graphColumn) {
        // Figure out the difference in width vs offsetWidth so we can properly set that up...
        curWidth = parseInt(graphColumn.style.width);
        if (!curWidth) {
          graphColumn.style.width = ColumnDef["Width"] + "px";
          curWidth = parseInt(graphColumn.style.width);
        }
        widthDiff = parseInt(graphColumn.offsetWidth) - curWidth;
        if (!widthDiff) {
          widthDiff = 0;
        }

        newWidth = ColumnDef["Width"] - widthDiff;
        if (newWidth < 0) {
          newWidth = 5;
        }

        if (curWidth != newWidth) {
          graphColumn.style.width = newWidth + "px";
        }

        if (graphColumn.style.left != lgraphWidth + "px") {
          graphColumn.style.left = lgraphWidth + "px";
        }

        lgraphWidth += parseInt(graphColumn.offsetWidth);

        lastSplitter = document.getElementById("col_split" + columnloop);
        lastSplitter.style.left = (lgraphWidth - widthDiff-1) + "px";

        $("#colheader_" + columnloop).width(newWidth + 3 + "px");
      }
    }
  }

  if (lastSplitter) {
    lastSplitter.className = "colsizer_last";
    $("#tracegraphbody .colsizer_last").addTouch();
  }

  return lgraphWidth;
}

function start_col_drag(evt, colnum) {
  if (evt) {
    splitPosX = evt.clientX;

    curMovingSplitter = document.getElementById("col_split" + colnum);

    clearTimeout(refreshTimerID);
    refreshTimerID = null;
    curSizingColNum = colnum;

    if (evt.stopPropagation && evt.preventDefault) {
      evt.stopPropagation();
      evt.preventDefault();
    }
    if (window.event) {
      window.event.cancelBubble = true;
      window.event.returnValue = false;
    }
    document.body.style.cursor = "ew-resize";
    return false;
  }
}

function move_col_drag(evt) {
  if ((curMovingSplitter) && splitPosX) {
    evt = fixEvent(evt);
    var newX = evt.clientX;
    var Delta = (newX - splitPosX);
    var oldWidth = parseInt(columnDefinition[curSizingColNum]["Width"]);

    if (oldWidth + Delta < 2) {
      Delta = oldWidth - 2;
    }
    curMovingSplitter.style.left = parseInt(curMovingSplitter.style.left) + Delta + "px";
    columnDefinition[curSizingColNum]["Width"] = oldWidth + Delta;

    splitPosX = splitPosX + Delta;
    if (evt.stopPropagation && evt.preventDefault) {
      evt.stopPropagation();
      evt.preventDefault();
    }
    if (window.event) {
      window.event.cancelBubble = true;
      window.event.returnValue = false;
    }
    return false;
  }
}

function colWidthsChanged() {
  // Write the changes to a Cookie - we're saving all our column widths in a Cookie because
  // writing it to the server doesn't really give us everything we might want (like resizing the server,
  // and fighting with form widths on the server).
  var ColWidths = Object();

  for (columnloop = 0; columnloop < columnDefinition.length; columnloop++) {
    ColumnDef = columnDefinition[columnloop];
    ColWidths[ColumnDef["Name"]] = ColumnDef["Width"];
    if (ColumnDef["Visible"] == 0) {
      ColWidths[ColumnDef["Name"]] *= -1;
    }
  }

  var objAsString = JSON.stringify(ColWidths);

  var expires = new Date();
  expires.setTime(expires.getTime() + 1000 * 60 * 24 * 7);
  set_cookie("colwidths-" + (IsSummary ? "SUM" : "TARGET"), encodeURIComponent(objAsString), expires);

  updateTraceGraph();
  set_cookie("totalwidth-" + (IsSummary ? "SUM" : "TARGET"), parseInt(document.getElementById("mainpage").style.width), expires);

  restartRefreshTimer(1000);
}

function colVisibleChange(colNumber, Visible) {
  columnDefinition[colNumber]["Visible"] = Visible;
  numHop = -1; // Force a full redraw
  colWidthsChanged();
}

function stop_col_drag(evt) {
  if ((curMovingSplitter) && (splitPosX)) {
    evt = fixEvent(evt);
    curMovingSplitter = null;
    splitPosX = null;

    document.body.style.cursor = "auto";
    numHop = 0;

    colWidthsChanged();

    return false;
  }
}

function showTargetGraph(UniqueID) {
  location.href = "?ID=" + UniqueID;
}

function elemToRowCol(clickTarget)
{
  var rowData = {
    row: -1,
    col: -1
  };

  // Find the top level ID
  while ((clickTarget) && (!clickTarget.id)) {
    clickTarget = clickTarget.parentNode;
  }

  if ((!clickTarget) || (!clickTarget.id))
    return rowData;

  // Figure out which row we're in...
  var matchVar = clickTarget.id.match(/Row([0-9]{1,3})Col([0-9]{1,2})/i);

  if (matchVar) {
    rowData["row"] = matchVar[1];
    rowData["col"] = matchVar[2];
  } else {
    matchVar = clickTarget.id.match(/colheader_([0-9]{1,2})/i);
    if (matchVar) {
      rowData["row"] = -1;
      rowData["col"] = matchVar[1];
    } else {
      matchVar = clickTarget.id.match(/SummaryCol([0-9]{1,2})/i);
      if (matchVar) {
        rowData["row"] = routeInfo.length;
        rowData["col"] = matchVar[1];
        return;
      }
    }
  }

  return rowData;
}

function onGraphContextPicked(e, context, item) {

  switch( item.attr('action') )
  {
    case 'hidecolumn': colVisibleChange( item.attr('col'), 0); break;
    case 'showcolumn': colVisibleChange( item.attr('col'), 1); break;
    case 'sortdescending': refreshContent({"setsortcol": "-" + columnDefinition[item.attr('col')]["Name"]}); break;
    case 'sortascending': refreshContent({"setsortcol":columnDefinition[item.attr('col')]["Name"]}); break;
    case 'stopsorting': refreshContent({"setsortcol":""}); break;
    case 'whoislookup': window.open('http://www.whois.sc/'+item.attr('value'), '_blank'); break;
    case 'showtargetgraph': showTargetGraph(item.attr('uniqueid')); break;
    case 'hidetimegraph': show_time_graph(item.attr('host'), false); break;
    case 'showtimegraph': show_time_graph(item.attr('host'), true); break;
    case 'showalltimegraphs': show_all_time_graphs(true); break;
    case 'hidealltimegraphs': show_all_time_graphs(false); break;
    case 'removefromsummary': refreshContent({cmd: "removehost", "host" : item.attr('host')}); break;
    case 'showonsummary': curTargetID = item.attr('summary'); refreshContent({cmd: addhost, host: item.attr('host')}); break;
    case 'createnewsummary':
      var newSummaryName = prompt("Enter name for new summary:", "");
      if ((newSummaryName != null) && (newSummaryName > "")) {
        refreshContent({cmd: "newsummary", "name" : newSummaryName });
      }
      break;
  }

}

function onGraphContextShow(evt, context) {

  var RowCol = elemToRowCol( evt.target );
  var rowNum = RowCol['row'];
  var colNum = RowCol['col'];

  var menuItems = $("#menu").empty();

  if ((rowNum < 0) && (colNum >= 0)) {
    // It's the column header

    // push in the current column "placeholder" - we'll fill it in later.
    columnDef = columnDefinition[colNum];

    $("<li>Hide <b>" + columnDef["Caption"] + "</b> column</li>").appendTo(menuItems).attr('col', colNum).attr('action', 'hidecolumn');
    // Do we need to be able to sort the target list?
    if (IsSummary) {
      if ((columnDef["ColumnType"] != ctHop) && (columnDef["ColumnType"] != ctGraph)) {
        if (targetFields["SortColumn"] == columnDef["Name"]) {
          $("<li>Sort by " + columnDef["Caption"] + " column (descending)</li>").appendTo(menuItems).attr('col', colNum).attr('action', 'sortdescending');
        } else {
          $("<li>Sort by " + columnDef["Caption"] + " column</li>").appendTo(menuItems).attr('col', colNum).attr('action', 'sortascending');
        }
      } else {
        if (targetFields["SortColumn"] > "") {
          $("<li>Stop sorting targets</li>").appendTo(menuItems).attr('col', colNum).attr('action', 'stopsorting');
        }
      }
    }

    var columnloop;
    var columnDef;
    var needsHR = true;

    for (columnloop = 0; columnloop < columnDefinition.length; columnloop++) {
      columnDef = columnDefinition[columnloop];
      if (columnDef["Visible"] == 0) {
        if (needsHR) {
          $('<li class="separator"></li>').appendTo(menuItems);
          needsHR = false;
        }
        $("<li>Show <b>" + columnDef["Caption"] + "</b> column</li>").appendTo(menuItems).attr('col', columnloop).attr('action', 'showcolumn');
      }
    }
  } else {
    // It's a body...

    // Get the data for the selected row...
    var CurHopData = routeInfo[rowNum];

    if (CurHopData["DNSName"] > "-") {
      $('<li>'+CurHopData["DNSName"]+'</li>').appendTo(menuItems);
    }
    if (CurHopData["IP"] > "-") {
      $('<li>'+CurHopData["IP"]+'</li>').appendTo(menuItems);
    } else {
      $('<li>No response at hop ' + CurHopData["HopNum"]+'</li>').appendTo(menuItems);
    }
    $('<li class="separator"></li>').appendTo(menuItems);

    if (CurHopData["DNSName"] > "-") {
      $('<li>Whois Lookup: Name</li>').appendTo(menuItems).attr('action','whoislookup').attr('value',CurHopData["DNSName"]);
    }
    if (CurHopData["IP"] > "-") {
      $('<li>Whois Lookup: IP Address</li>').appendTo(menuItems).attr('action','whoislookup').attr('value',CurHopData["IP"]);
    }
    $('<li class="separator"></li>').appendTo(menuItems);

    var rowNumEntry = rowNum;
    if ((Number(rowNum) == routeInfo.length - 1) && (targetFields) && (Number(targetFields["ReachedDestination"]))) {
      rowNumEntry = -1;
    }

    if (CurHopData["IP"] > "-") {
      var subParts = $("<ul>");
      summaryList.forEach(function(summary) {
        // Can't add to the All Targets screen (CanClose = false), or to the screen we're currently looking at.
        if (((!IsSummary) || (targetFields["UniqueID"] != summary["UniqueID"])) && (summary["CanClose"] != 0)) {
          $('<li>' + summary["SummaryName"] + "</li>").appendTo(subParts).attr('action', 'showonsummary').attr('summary', summary['UniqueID']).attr('host', CurHopData["UniqueID"]);
        }
      });
      $('<li>Create new summary</li>').appendTo(subParts).attr('action', 'createnewsummary').attr('host', CurHopData["UniqueID"]);
      $('<li>Show on summary</li>').appendTo(menuItems).append(subParts);
      if ((IsSummary) && (targetFields['CanClose'] != 0)) {
        $('<li>Remove from summary</li>').appendTo(menuItems).attr('action','removefromsummary').attr('host', CurHopData["UniqueID"]);
      }
    }

    if (IsSummary) {
      $('<li>Show trace graph</li>').appendTo(menuItems).attr('action','showtargetgraph').attr('uniqueid',CurHopData["UniqueID"]);
    }

    if (CurHopData["IP"] > "-") {
      if (isTimeGraphVisible(CurHopData["UniqueID"])) {
        $('<li>Hide this Timeline Graph</li>').appendTo(menuItems).attr('action','hidetimegraph').attr('host',CurHopData["UniqueID"])
      } else {
        $('<li>Show this Timeline Graph</li>').appendTo(menuItems).attr('action','showtimegraph').attr('host',CurHopData["UniqueID"])
      }
    }

    if ((IsSummary) && (eligibleTimeGraphTargets > 0)) {
      $('<li class="separator"></li>').appendTo(menuItems);
      if (eligibleTimeGraphTargets > visibleTimeGraphTargets) {
        $('<li>Show <b>all</b> Timeline Graphs</li>').appendTo(menuItems).attr('action','showalltimegraphs');
      }
      if (visibleTimeGraphTargets > 0) {
        $('<li>Hide <b>all</b> Timeline Graphs</li>').appendTo(menuItems).attr('action','hidealltimegraphs');
      }
    }
  }

  if (isIphone) {
    $('<li class="separator"></li>').appendTo(menuItems);
    $('<li>Close Menu</li>').appendTo(menuItems);
  }

  return;
}

function first_col_double_click(evt) {

  var clickTarget;
  if (window.event && window.event.srcElement)
    clickTarget = window.event.srcElement;

  else if (evt && evt.target)
    clickTarget = evt.target;

  // Find the top level ID
  while ((clickTarget) && (!clickTarget.id)) {
    clickTarget = clickTarget.parentNode;
  }

  if ((!clickTarget) || (!clickTarget.id))
    return;

  // Figure out which row we're in...
  var matchVar = clickTarget.id.match(/Row([0-9]{1,3})Col([0-9]{1,2})/i);
  var rowNum;
  var colNum;
  var SelHostID = "";

  if (matchVar) {
    rowNum = Number(matchVar[1]);
    colNum = matchVar[2];
  } else {
    matchVar = clickTarget.id.match(/colheader_([0-9]{1,2})/i);
    if (matchVar) {
      rowNum = -1;
      colNum = matchVar[1];
    } else {
      matchVar = clickTarget.id.match(/SummaryCol([0-9]{1,2})/i);
      if (!matchVar) {
        return;
      }
      rowNum = routeInfo.length;
      colNum = matchVar[1];
    }
  }

  if (Number(colNum) != 0) {
    return;
  }

  if ((rowNum > routeInfo.length - 1) && (targetFields) && (!Number(targetFields["ReachedDestination"]))) {
    SelHostID = targetFields["FinalDestinationID"];
  } else if (rowNum < routeInfo.length) {
    if (String(routeInfo[rowNum]["IP"]) > "-") {
      SelHostID = routeInfo[rowNum]["UniqueID"];
    }
  }
  if (SelHostID > "") {
    show_time_graph(SelHostID, !isTimeGraphVisible(SelHostID));
  }
}

function isTimeGraphVisible(HostID) {
  if (HostID == targetFields["FinalDestinationID"]) {
    return (visibleTimeGraphs[HostID] != "hide")
  } else {
    return Boolean(visibleTimeGraphs[HostID]);
  }
}

function show_time_graph(HostID, Visible) {

  if (HostID != targetFields["FinalDestinationID"]) {
    if (Visible) {
      visibleTimeGraphs[HostID] = Visible;
    } else {
      delete visibleTimeGraphs[HostID];
    }
  } else {
    if (!Visible) {
      visibleTimeGraphs[HostID] = "hide";
    } else {
      delete visibleTimeGraphs[HostID];
    }
  }

  var expires = new Date();
  expires.setTime(expires.getTime() + 1000 * 60 * 24 * 365);	 // 1 year expiration on visible graph list.

  set_associated_array("visibleTimeGraphs-" + curTargetID, visibleTimeGraphs, expires);

  // refreshTimeGraphs(graphWidth, timeGraphHeight);
  updateTraceGraph(null);
}

function show_all_time_graphs(Visible) {
  // Figure out how many graphs should be shown here.
  for (var hoploop = 0; hoploop < routeInfo.length; hoploop++) {
    if (Visible) {
      visibleTimeGraphs[routeInfo[hoploop]["UniqueID"]] = Visible;
    } else {
      delete visibleTimeGraphs[routeInfo[hoploop]["UniqueID"]];
    }
  }
  var expires = new Date();
  expires.setTime(expires.getTime() + 1000 * 60 * 24 * 7);	// 1 year expiration on visible graph list.
  set_associated_array("visibleTimeGraphs-" + curTargetID, visibleTimeGraphs, expires);
  updateTraceGraph(null);
}

// This modifies the fields on the form to make it match the PingPlotter data.
// We don't want to edit the field that we're in, which is why all the :not(:focus) stuff
function updateFormFields(targetData) {

  if (targetData["UniqueID"]) {
    if (curTargetID != targetData["UniqueID"]) {
      curTargetID = targetData["UniqueID"];
    }
  }

  if (prevTargetID != curTargetID) {
    $("#targetinput").val('');

    // Different target, so do some up-front setup...
    IsSummary = (curTargetID.substring(0, 4) == "SUM-");

    if (IsSummary) {
      $(".target_setting").hide();
      $(".summary_setting").show();
    } else {
      $(".target_setting").show();
      $(".summary_setting").hide();
    }
    $("#printableversion a").attr("href", "?ID=" + curTargetID + "&Printable=1");
  }

  if (targetData["TraceInterval"]) {
    curTraceInterval = Number(targetData["TraceInterval"]);
  }

  var targetValue;

  if (IsSummary) {
    $("#curTargetDesc").setHTMLIfDifferent("<span class=\"main-target-name\">" + targetFields["SummaryName"] + "</span>");
    document.title = 'PingPlotter - '+targetFields["SummaryName"];
  } else {
    document.title = 'PingPlotter - '+targetData["TargetDescription"];
    $("#curTargetDesc").setHTMLIfDifferent(
      ("Target: <span class=\"main-target-name\">" + targetData["TargetDNSName"] + " (" + targetData["TargetIPAddress"] + ")")
      +
      (((targetData["IsRunning"] == 0) && (targetData["SampleCount"] > 0)) ? " - (Paused)" : "")+"</span>");
  }


  if (!IsSummary) {
    $("#editTraceCount:not(:focus)").val((Number(targetData["TraceCount"]) == 0)?"Unlimited":targetData["TraceCount"]);
    $("#selectTraceInterval:not(:focus)").each(function () {
      if (Number(this.value) != Number(targetData["TraceInterval"])) {
        // If trace interval doesn't match, then let's clear it.
        var x = jQuery('#selectTraceInterval option');

        // If it's not in the list, we need to fix that.
        if ($("#selectTraceInterval option[value=\"" + targetData["TraceInterval"] + "\"]").length == 0) {
          x.remove(); // Pull all the options out of the dropdown
          // Add the non-matching one in
          x = x.add(new Option(secondsToTime(targetData["TraceInterval"] / 1000), targetData["TraceInterval"]));
          x.sort(function (a, b) {
            if (a.value == b.value) return 0;
            return (Number(a.value) > Number(b.value)) ? 1 : -1;
          });
          x.appendTo($('#selectTraceInterval'));
        }

        // If it's in the list, then we can just do it.  If it's not, we need to insert it in there...
        this.value = targetData["TraceInterval"];
      }
    });

    $("#selectSettingsName:not(:focus)").each(function () {
      if (Number(this.value) != Number(targetData["SettingsName"])) {
        this.value = targetData["SettingsName"];
      }
    });

    $("#editSamplesToInclude:not(:focus)").each(function () {
      if (Number(targetData["SamplesToInclude"]) == 0) {
        targetValue = "All";
      } else {
        targetValue = targetData["SamplesToInclude"];
      }
      if (this.value != targetValue) {
        this.value = targetValue;
      }
    });
  }

  $("#selectTimeGraphTime:not(:focus)").each(function () {
    if (Number(this.value) != Number(targetData["TimeGraphTime"])) {
      this.value = targetData["TimeGraphTime"];
    }
  });

  if (IsSummary) {
    $("#selectSummaryFocus:not(:focus)").each(function () {
      if (Number(this.value) != Number(targetData["FocusPeriod"])) {
        // If trace interval doesn't match, then let's clear it.
        var x = jQuery('#selectSummaryFocus option');

        // If it's not in the list, we need to fix that.
        if ($("#selectSummaryFocus option[value=\"" + targetData["FocusPeriod"] + "\"]").length == 0) {
          x.remove(); // Pull all the options out of the dropdown
          // Add the non-matching one in
          x = x.add(new Option(secondsToTime(targetData["FocusPeriod"]), targetData["FocusPeriod"]));
          x.sort(function (a, b) {
            if (a.value == b.value) return 0;
            return (Number(a.value) > Number(b.value)) ? 1 : -1;
          });
          x.appendTo($('#selectSummaryFocus'));
        }

        // If it's in the list, then we can just do it.  If it's not, we need to insert it in there...
        this.value = targetData["FocusPeriod"];
        $("#nonStandardFocus").hide();
      }
    });
  }

  if ((!IsSummary) || (!(targetData["CanClose"] != 0))) {
    $("#btnCloseSummary").hide();
  } else {
    $("#btnCloseSummary").show();
  }
  if (!IsSummary) {
    $("#btnRenameSummary").hide();
  } else {
    $("#btnRenameSummary").show();
  }

  if ((targetData["IsRunning"] != 0) && (!IsSummary)){
    $("#btnStop").show();
  } else {
    $("#btnStop").hide();
  }

  if ((targetData["IsRunning"] == 0) && (targetData["SampleCount"] > 0)) {
    $("#btnResume").show();
  } else {
    $("#btnResume").hide();
  }

  if (targetData["SampleCount"] > 0) {
    $("#btnReset, #btnDownload, #btnClose").show();
  } else {
    $("#btnReset, #btnDownload, #btnClose").hide();
  }

  $("#btnDownload").attr("href", "GetSampleData.asp?ID=" + targetData["UniqueID"]);

  prevTargetID = curTargetID;

}

// A *DOOZY* routine - paints the upper trace graph using
// HTML / DOM / CSS instead of .gif / .png images.  This routine
// has some opportunity for optimization, but we'll flush it out
// to feature complete first.  After some time in the field, we'll
// see what we can do to optimize things at all.
function updateTraceGraph(traceXML) {

  var curNode;
  var targetDataXML;



  if (traceXML) {
    curNode = traceXML.firstChild;
  } else {
    curNode = null;
  }

  while (curNode) {
    if (curNode.nodeName == "targetdetails") {
      targetDataXML = curNode;
      // OK, we have a target - let's convert that into an array
      targetFields = RecordToArray(targetDataXML);

      IsSummary = (targetFields["UniqueID"].substr(0,3) == "SUM");

      // targetData["UniqueID"];
    }
    if (curNode.nodeName == "graphcolumns") {

      var lObjString = decodeURIComponent(get_cookie("colwidths-" + (IsSummary ? "SUM" : "TARGET")));
      var lColWidths = new Object();
      try {
        lColWidths = JSON.parse(lObjString);
      } catch (e) {
      }
      var ColumnDef;

      columnDefinition = new Array();
      for (var cvtColumnIdx = 0; cvtColumnIdx < curNode.childNodes.length; cvtColumnIdx++) {
        ColumnDef = RecordToArray(curNode.childNodes.item(cvtColumnIdx));

        try {
          // Override column widths & visibility with local cookie value, if it exists.
          if (lColWidths[ColumnDef["Name"]]) {
            ColumnDef["Width"] = lColWidths[ColumnDef["Name"]];
            if (ColumnDef["Width"] < 0) {
              ColumnDef["Visible"] = 0;
              ColumnDef["Width"] *= -1;
            } else {
              ColumnDef["Visible"] = 1;
            }
          }
        } catch (e) {
          // Ignore missing columns, etc.
        }
        columnDefinition.push(ColumnDef);
      }

      numHop = -1; // Reset the stored value so we force a refresh.
    }
    curNode = curNode.nextSibling;
  }

  if (targetDataXML) {
    var hops = targetDataXML.firstChild;
    while (hops) {
      if (hops.nodeName == "hosts") {
        var hoploop;
        routeInfo = Array(hops.childNodes.length);
        for (hoploop = hops.childNodes.length - 1; hoploop >= 0; hoploop--) {
          routeInfo[hoploop] = RecordToArray(hops.childNodes.item(hoploop));
        }
        break;
      }
      hops = hops.nextSibling;
    }
  }

  if (!targetFields) {
    return;
  }


  // Update the trace interval from the current target..
  updateFormFields(targetFields);

  if (IsSummary) {
    $(".headernamecaption").setHTMLIfDifferent("");
    $("#topTargetName").setHTMLIfDifferent("Summary: " + targetFields["SummaryName"]);
    $("#headertargetname").setHTMLIfDifferent(targetFields["SummaryName"]);
    $("#headertargetip").setHTMLIfDifferent(targetFields["TargetIPAddress"]);
  } else {
    $(".headernamecaption").setHTMLIfDifferent("Target Name:");
    $("#headertargetname").setHTMLIfDifferent((targetFields["TargetDNSName"]) ? targetFields["TargetDNSName"] : "No target");
    $("#headertargetip").setHTMLIfDifferent((targetFields["TargetIPAddress"]) ? targetFields["TargetIPAddress"] : "No target");
  }

  if (IsSummary) {
    if (targetFields["HostCount"] > 0) {
      $("#headersamplerange").setHTMLIfDifferent((targetFields["StartFocusTime"]) ? (targetFields["StartFocusTime"] + " - " + targetFields["EndFocusTime"]) : ("No data collected."));
    } else {
      $("#headersamplerange").setHTMLIfDifferent("No targets in this summary.");
    }
  } else {
    $("#headersamplerange").setHTMLIfDifferent((targetFields["StartFocusTime"]) ? (targetFields["StartFocusTime"] + " - " + targetFields["EndFocusTime"]) : ("Not tracing"));
  }

  // Get the hops!

  var targethtml;
  var columnloop;
  var ColumnDef;

  var WarningSpeed = Number(targetFields["WarningSpeed"]);
  var BadSpeed = Number(targetFields["BadSpeed"]);
  var Unreachable = false;
  var graphRows = routeInfo.length;
  var CurHopData;
  var hasSummaryRow = false;
  var tempText;
  var fullRefresh;

  var popupMenuText = "";
  // iPhone doesn't support right-click.  Need to put some explicit click regions in.
  if (isIphone) {
    popupMenuText = ' onclick="javascript:graphrightclick()"';
  }


  if (!IsSummary) {
    for (hoploop = graphRows - 1; hoploop >= 0; hoploop--) {
      CurHopData = routeInfo[hoploop];
      if (CurHopData["GoodCount"] > 0) {
        break;
      }
      graphRows--;
      Unreachable = true;
    }
  }

  var displayableHops = graphRows;

  // If we have any samples here, let's add a row for "Unreachable" or "Error"
  if (!IsSummary) {
    if ((CurHopData) && (((CurHopData["GoodCount"] > 0) && (Number(targetFields["ReachedDestination"]) != 0)) || Unreachable)) {
      graphRows++;
      hasSummaryRow = true;
    }
  }

  // Nothing to paint!  Hide everything that might be showing here.
  if (graphRows == 0) {
    $("#tracegraphbody").setHTMLIfDifferent("");
    refreshTimeGraphs(graphWidth, timeGraphHeight);
    $("#tracegraphbody").height(0);
    return;
  }

  fullRefresh = false;
  // Do we need to refresh everything?  If the row count has changed, or if the visibility of
  // the summary row has changed, then we need to do a full rebuild.
  if ((numHop != graphRows) ||
    (hasSummaryRow != Boolean(document.getElementById("SummaryRowBackground"))) ||
    ($("#tracegraphbody").height() == 0)) {
    fullRefresh = true;
  }

  if (fullRefresh) {

    // Figure out how many rows we actually want to show here.
    targethtml = '<div class="tracegraphtable" style="overflow:hidden;white-space:nowrap;">';
    if (hasSummaryRow) {
      targethtml += "<div id=\"SummaryRowBackground\" class=\"SummaryRowBackground\" style=\"position:absolute\"></div>";
    }
    var ColClass;

    for (columnloop = 0; columnloop < columnDefinition.length; columnloop++) {

      ColumnDef = columnDefinition[columnloop];

      // If this column is visible, display it - otherwise, ignore it
      if (ColumnDef["Visible"] != 0) {

        // Figure out the Style class name for this column.
        ColClass = "Col_" + ColumnDef["Name"];
        if (!HeightSetter) {
          HeightSetter = "Graph_Col" + columnloop;
        }

        // Open up the div for this whole column
        targethtml += '<div class="' + ColClass + '" id="Graph_Col' + columnloop + '" style="position:absolute;overflow:hidden;white-space:nowrap;';
        if (Number(ColumnDef["ColumnType"]) != ctGraph) {
          targethtml += 'padding-right:3px;';
        }
        targethtml += '">';

        // Add in the div for the header
        if ((ColumnDef["ColumnType"] == ctHop) && (IsSummary)) {
          tempText = "&nbsp;";
        } else {
          tempText = ColumnDef["Caption"];
        }
        targethtml += '<div class="tracegraphcolumnheader" id="colheader_' + columnloop + '" ' + popupMenuText + '>' + tempText + "</div>";

        // The graph column is different from the rest, so add in the div for that separately.
        if (Number(ColumnDef["ColumnType"]) == ctGraph) {
          targethtml += "<div id=\"GraphArea\"><div style=\"position:relative;\" id=\"TraceGraphCanvas\"></div></div>";
        } else {
          // Iterate all the rows of the graph and fill in cells for them
          for (var hoploop = 0; hoploop < displayableHops; hoploop++) {
            targethtml += '<div id="Row' + hoploop + 'Col' + ColumnDef["ColIndex"] + '"';
            if (ColumnDef["ColumnType"] == ctHop) {
              targethtml += popupMenuText;
            }
            targethtml += '></div>\n';
          }
          // Add +1 so there is room for "Unreachable" and/or "Round Trip" row...
          if (hasSummaryRow) {
            targethtml += '<div id="SummaryCol' + ColumnDef["ColIndex"] + '"></div>\n';
          }
        }
        targethtml += "</div>"; // Close the div for this column
        targethtml += '<div id="col_split' + columnloop + '" class="colsizer" col="' + columnloop + '"><div>&nbsp;</div></div>';
      }
    }
    targethtml += "</div>"; // Close out the div for the whole "Table" area.

    // Check to see if we need to add "Round Trip" or "Unreachable" to the end of the graph....

    $("#tracegraphbody").setHTMLIfDifferent(targethtml);

    $("#tracegraphbody .colsizer").mousedown(function (e) {
      start_col_drag(e, $(this).attr("col"));
    }).addTouch();
    $("#tracegraphbody .colsizer_last").addTouch();


    numHop = graphRows;

    jg = null; // Get rid of the graphic canvas...

  }

  var MaxNum = parseInt(targetFields["GraphScale"]);
  var ColHTML;

  graphWidth = updateColWidths();
  $("#tracegraph").width(graphWidth);

  var pageWidth = graphWidth + 38;

  // If the summary list is showing (should only be one!), add the width.
  if ($("#summarylist").outerWidth()) {
    pageWidth += $("#summarylist").outerWidth()+20;
  }

//  $("#mainpage").width(pageWidth);

  var totalHeight = 0;
  var headerHeight = 0;
  var totalWidth;
  var summaryRow = false;
  var summaryHeight = 0;
  var summaryTop = 0;
  var curCell;
  var timeGraphAddl;
  var firstVisibleColumn = 0;
  var hoploop;
  while (columnDefinition[firstVisibleColumn]["Visible"] == 0) {
    firstVisibleColumn++;
  }

  // Iterate all the targets and fill in the display values
  for (hoploop = 0; hoploop < graphRows; hoploop++) {

    if (hoploop < displayableHops) {
      summaryRow = false;
      CurHopData = routeInfo[hoploop];

      if (Number(CurHopData["Max"]) > MaxNum) {
        MaxNum = Number(CurHopData["Max"]);
      }
    } else {
      summaryRow = true;
      CurHopData = routeInfo[hoploop - 1];
    }

    for (columnloop = 0; columnloop < columnDefinition.length; columnloop++) {

      ColumnDef = columnDefinition[columnloop];

      if ((ColumnDef["Visible"] != 0)) {
        ColHTML = "&nbsp;";
        if ((!summaryRow) || (!Unreachable)) {
          switch (Number(ColumnDef["ColumnType"])) {
            case ctHop:
            {
              if (!summaryRow) {
                if (!IsSummary) {
                  ColHTML = CurHopData["HopNum"];
                } else {
                  ColHTML = "&nbsp;"
                }
                if (Number(CurHopData["Avg"] > BadSpeed)) {
                  ColHTML = "<div class=\"Hop_Bad\">" + ColHTML + "</div>";
                } else if (Number(CurHopData["Avg"] > WarningSpeed)) {
                  ColHTML = "<div class=\"Hop_Warn\">" + ColHTML + "</div>";
                } else if (CurHopData["GoodCount"] > 0) {
                  ColHTML = "<div class=\"Hop_Good\">" + ColHTML + "</div>";
                } else {
                  ColHTML = "<div class=\"Hop_None\">" + ColHTML + "</div>";
                }
              }
              break;
            }
            case ctPacketLoss:
              pcktLoss = Number(CurHopData["PL"].replace(",", ".")); // Might be internationally formatted.
              if (pcktLoss == 0) {
                ColHtml = "&nbsp;";
              } else {
                ColHTML = pcktLoss.toFixed(2);
                if (decimalPointChar != '.') {
                  ColHTML = ColHTML.replace('.', decimalPointChar);
                }
              }
              break;
            case ctIP:
              if (!summaryRow) {
                if (IsSummary) {
                  ColHTML = "<a class=\"target_nav\" href=\"?ID=" + CurHopData["UniqueID"] + "\">" + CurHopData["IP"] + "</a>";
                } else {
                  ColHTML = CurHopData["IP"]
                }
              }
              ;
              break;
            case ctDNSName:
              if (!summaryRow) {
                ColHTML = CurHopData["DNSName"];
              } else {
                ColHTML = "Round Trip:";
              }
              ;
              break;
            case ctAvgTime:
            case ctMinTime:
            case ctMaxTime:
              ColHTML = (CurHopData["GoodCount"] > 0) ? CurHopData[ColumnDef["Name"]] : "&nbsp;";
              break;
            case ctCurTime:
              ColHTML = (CurHopData["GoodCount"] > 0) ? CurHopData["Cur"] : "&nbsp;";
              if (Number(ColHTML) == -32768) {
                ColHTML = "ERR";
              }
              break;
            case ctUser:
              ColHTML = CurHopData[ColumnDef["Name"]];
              break;
            case ctErr:
              ColHTML = (CurHopData[ColumnDef["Name"]] > 0 ? CurHopData[ColumnDef["Name"]] : "&nbsp;");
              break;
            case ctGraph:
              ColHTML = "&nbsp;";
              if (!totalWidth) {
                totalWidth = parseInt(ColumnDef["Width"]);
              }
              break;  // Don't do anything for the graph...
            default:
              ColHTML = "Unknown!";
              break;

          }
        } else {
          switch (Number(ColumnDef["ColumnType"])) {
            case ctDNSName:
              ColHTML = "Destination Unreachable";
              break;
          }
        }
        if (typeof(ColHTML) == "undefined") {
          ColHTML = "&nbsp;";
        }
        if (ColHTML == "") {
          ColHTML = "&nbsp;";
        }

        // Get the initial row height for first visible column...
        if (headerHeight == 0) {
          headerHeight = $("#colheader_" + columnloop).outerHeight();
        }

        if (!summaryRow) {
          // Do we need to indicate in the hop column that the time graph is there?
          if ((Number(ColumnDef["ColumnType"]) == ctHop) && (isTimeGraphVisible(CurHopData["UniqueID"]))) {
            $("#Row" + hoploop + 'Col' + ColumnDef["ColIndex"]).setHTMLIfDifferent(ColHTML).
              prepend(function () {
                      return '<div class="visible-time-graph"></div>'
              });
          } else {
            $("#Row" + hoploop + 'Col' + ColumnDef["ColIndex"]).setHTMLIfDifferent(ColHTML);
          }

        } else {
          $("#SummaryCol" + ColumnDef["ColIndex"]).setHTMLIfDifferent(ColHTML).addClass((Unreachable) ? "UnreachableRow" : "ReachedTargetRow").removeClass((Unreachable) ? "ReachedTargetRow" : "UnreachableRow");
          if (!summaryHeight) {
            summaryHeight = $("#SummaryCol" + ColumnDef["ColIndex"])[0].offsetHeight;
            summaryTop = $("#SummaryCol" + ColumnDef["ColIndex"])[0].offsetTop;
          }
        }
      }
    }
    // Summary row is the last "Round Trip" row.
    if (!summaryRow) {
      $("#Row" + hoploop + 'Col' + firstVisibleColumn).each(function() {
        totalHeight = $(this).position().top + $( this ).outerHeight();
      })
    }
  }

  // IE7 doesn't build the graph right sometimes, so we need to refresh the columns again after writing in the row values.
  if (fullRefresh) {
    graphWidth = updateColWidths();
  }

  if (IsSummary) {
    $(".target_nav").click(function () {
        curTargetID = $(this).attr("href").split("=")[1];
        refreshContent({}, true);
        return false;
      }
    );
  }

  // Check to see if we need to add "Round Trip" or "Unreachable" to the end of the graph....
  if (hasSummaryRow) {
    $("#SummaryRowBackground")
      .removeClass()
      .addClass(Unreachable ? "UnreachableRow" : "ReachedTargetRow")
      .addClass("SummaryRowBackground")
      .css({
        'position': 'absolute',
        'left': '0px',
        'top': summaryTop + "px",
        'height': summaryHeight + "px",
        'width': graphWidth + "px"
      });
  }
  $("#tracegraphbody").height(Number(totalHeight) + Number(summaryHeight) + "px");

  // Draw on the graph!
  var traceCanvas = document.getElementById("TraceGraphCanvas");

  // If we don't have a trace canvas, or if we don't have any rows shown (totalWidth is undefined in that case), then don't paint the graph
  if ((traceCanvas) && (totalWidth)) {
    traceCanvas.style.width = totalWidth + "px";
    traceCanvas.style.height = Number(totalHeight) - Number(headerHeight) + "px";


    if (jg) {
      jg.htm = ""; // Clear the html
    } else {
      jg = new jsGraphics("TraceGraphCanvas");
      $("#TraceGraphCanvas").append("<div class=\"tracegraphscale\">0 ms</div>");
    }

    var goodPoint, warnPoint, badPoint;

    goodPoint = Math.round((WarningSpeed / MaxNum) * totalWidth);
    warnPoint = Math.round((BadSpeed / MaxNum) * totalWidth);

    // Figure out the size of the background colors
    if (goodPoint > totalWidth) {
      goodPoint = totalWidth;
      warnPoint = 0;
      badPoint = 0;
    } else if (warnPoint > totalWidth) {
      warnPoint = totalWidth;
      badPoint = 0;
    } else {
      badPoint = totalWidth;
    }

    // Draw in the background colors
    jg.setColor(GOOD_BG_COLOR);
    jg.fillRect(0, 0, goodPoint, totalHeight);

    if (warnPoint > 0) {
      jg.setColor(WARN_BG_COLOR);
      jg.fillRect(goodPoint, 0, warnPoint - goodPoint, totalHeight);

      if (badPoint > 0) {
        jg.setColor(BAD_BG_COLOR);
        jg.fillRect(warnPoint, 0, badPoint - warnPoint, totalHeight);
      }
    }

    // Iterate through and draw the avg lines.
    // Iterate all the targets and fill in the display values
    var lastX = -1;
    var lastY = -1;
    var minPos, maxPos, plWidth;
    var CurX;
    var mostRecent;

    var CurY = 18 / 2; // Default to "something"
    var rowHeight;

    if (document.getElementById("Row0Col" + firstVisibleColumn)) {
      rowHeight = document.getElementById("Row0Col" + firstVisibleColumn).offsetHeight;
      CurY = Math.round(rowHeight / 2);
    }

    for (var hoploop = 0; hoploop < displayableHops; hoploop++) {
      CurHopData = routeInfo[hoploop];

      plWidth = Math.round((Number(CurHopData["PL"].replace(",", ".")) / 30) * totalWidth);
      // Don't show packet loss unless there's a host at this hop, and we have something to show.
      if ((plWidth > 0) && (CurHopData["IP"].length > 1)) {

        if (plWidth > totalWidth) {
          plWidth = totalWidth;
        }

        jg.htm += '<div class="PL_Bar" style="position:absolute;overflow:hidden;' +
        'left:0px;' +
        'top:' + (CurY - 5) + 'px;' +
        'width:' + plWidth + 'px;">' +
        formatNumDigits(CurHopData["PL"], 2) + "%&nbsp;packet&nbsp;loss<\/div>";
      }

      if (CurHopData["GoodCount"] > 0) {
        // Draw the packet loss line
        // Draw on the min/max line
        minPos = Math.round((Number(CurHopData["Min"]) / MaxNum) * totalWidth);
        if (minPos < totalWidth) {
          maxPos = Math.round((Number(CurHopData["Max"]) / MaxNum) * totalWidth);
          if (maxPos > totalWidth - 1) {
            maxPos = totalWidth - 1;
          }
          jg.setColor("black");

          jg.drawLine(minPos, CurY, Math.min(maxPos, totalWidth), CurY);
          jg.drawLine(minPos, CurY - 1, minPos, CurY + 1);
          if (maxPos <= totalWidth) {
            jg.drawLine(maxPos, CurY - 1, maxPos, CurY + 1);
          }
        }

        // Draw the average latency line
        CurX = Math.round((Number(CurHopData["Avg"]) / MaxNum) * totalWidth);
        jg.setColor("red");
        if (IsSummary) {
          jg.drawLine(CurX, CurY - (rowHeight / 2) - 1, CurX, CurY + (rowHeight / 2) - 1);
        } else {
          if (CurX > totalWidth) {
            CurX = totalWidth;
          }
          if (lastY > -1) {
            jg.drawLine(lastX, lastY, CurX, CurY);
          }
        }
        jg.fillEllipse(CurX - 1, CurY - 1, 4, 4);
        lastX = CurX;
        lastY = CurY;
      }
      mostRecent = Math.round((Number(CurHopData["Cur"]) / MaxNum) * totalWidth);
      if (mostRecent >= 0) {
        jg.htm += '<img src="images/cur_x.gif" style="position:absolute;width:7px;height:7px;top:' + (CurY - 3) + 'px;left:' + (mostRecent - 3) + 'px;">';
      }

      if (hoploop < (displayableHops - 1)) {
        CurY = CurY + $("#Row" + (hoploop + 1) + "Col" + firstVisibleColumn).outerHeight();
      }
    }
    if (jg.cnv) jg.cnv.innerHTML = jg.defhtm;
    jg.paint();

    $("#TraceGraphCanvas .tracegraphscale").setHTMLIfDifferent(MaxNum + " ms");

    $("#graphimage").hide();
    $("#tracegraph").show();
  }

  // Draw the divider line between targets for the summary graph screen
  if ((IsSummary) && (fullRefresh)) {

    var curLinePos;
    var graphCanvas;
    graphCanvas = new jsGraphics("tracegraphbody");
    curLinePos = headerHeight - 1;

    var curElement;

    // Iterate all the rows and put an underline in there...
    for (var hoploop = 0; hoploop < graphRows; hoploop++) {
      curElement = document.getElementById("Row" + hoploop + "Col" + firstVisibleColumn);
      curLinePos = curElement.offsetTop + curElement.offsetHeight - 1;
      graphCanvas.setColor("black");
      graphCanvas.drawLine(0, curLinePos, graphWidth - 1, curLinePos);
    }
    graphCanvas.paint();
  }


  refreshTimeGraphs(graphWidth, timeGraphHeight);
}


// Pull new images of the time graphs (and also make sure the right ones are
// being displayed...)
function refreshTimeGraphs(AWidth, AHeight) {

  var frameHTML = "";
  var graphframeurl;
  var hoploop;
  var frameCount = 0;
  var timeGraphList = new Array();
  var summarySpecifier;

  eligibleTimeGraphTargets = 0;
  visibleTimeGraphTargets = 0;

  // Figure out how many graphs should be shown here.
  for (hoploop = 0; hoploop < routeInfo.length; hoploop++) {
    eligibleTimeGraphTargets++;
    if ((targetFields["FinalDestinationID"] != routeInfo[hoploop]["UniqueID"]) && (isTimeGraphVisible(routeInfo[hoploop]["UniqueID"]))) {
      visibleTimeGraphTargets++;
      frameHTML += '<img id="timegraphframe' + timeGraphList.length + '"><br />';
      timeGraphList.push(routeInfo[hoploop]["UniqueID"]);
      if (!document.getElementById('timegraphframe' + hoploop)) {
        frameCount += 1000; // We need a refresh;
      }
    }
  }

  // The final hop should be shown by default, unless we're looking at the summary graph.
  if (!IsSummary) {
    summarySpecifier = "";
    if ((targetFields["FinalDestinationID"] > "") && (isTimeGraphVisible(targetFields["FinalDestinationID"]))) {
      frameHTML += '<img id="timegraphframe' + timeGraphList.length + '"><br />';
      timeGraphList.push(targetFields["FinalDestinationID"]);

      if (!document.getElementById('timegraphframe_target')) {
        frameCount += 1000; // We need a refresh;
      }
    }
  } else {
    summarySpecifier = "&Summary=" + curTargetID;
  }

  // Trim off the trailing <br />
  if (frameHTML.length >= 4) {
    frameHTML = frameHTML.substring(0, frameHTML.length - 4);
  }

  // *2 in there because we have the <br /> elements too, but not on the last one - so we add
  // 1 to the length for that last missing <br />
  if (frameHTML == "") {
    $("#timegraphframe").hide();
  } else {
    if ((timeGraphList.length * 2) != document.getElementById("timegraphframe").childNodes.length + 1) {
      $("#timegraphframe").setHTMLIfDifferent(frameHTML).show();
    } else {
      $("#timegraphframe").show();
    }
  }

  for (hoploop = 0; hoploop < timeGraphList.length; hoploop++) {
    graphObj = document.getElementById("timegraphframe" + hoploop);
    graphObj.width = AWidth;
    graphObj.height = AHeight;
    graphObj.src = 'GetImage.asp?ID=' + timeGraphList[hoploop] + '&ts=' + (new Date()).getTime() + '&Height=' + AHeight + '&Width=' + AWidth + '&Color=E9E9E9' + summarySpecifier;
  }

  if (timeGraphList.length > 0) {
    document.getElementById("timegraphtimechanger").style.display = "block";
  } else {
    document.getElementById("timegraphtimechanger").style.display = "none";
  }
}

function setRefreshInterval(intervalMS) {

  if (parseInt(intervalMS) == -2) {
    // Auto
    refreshInterval = -2;
    clearTimeout(refreshTimerID);
    refreshTimerID = 0;
    refreshContent();
    updateRefreshIntervalDisplay();
  } else if (parseInt(intervalMS) == -1) {
    // Stop refreshing.
    clearTimeout(refreshTimerID);
    refreshTimerID = 0;
    refreshInterval = -1;
    updateRefreshIntervalDisplay();
  } else if (parseInt(intervalMS) == 0) {
    // Refresh now.  Flash the "Now" button.
    var oldRefreshInterval = refreshInterval;
    refreshInterval = 0;
    updateRefreshIntervalDisplay();
    refreshInterval = oldRefreshInterval;
    clearTimeout(refreshTimerID);
    refreshTimerID = 0;
    refreshContent();
  } else {
    // Set the interval
    clearTimeout(refreshTimerID);
    refreshTimerID = setTimeout("refreshContent()", intervalMS);
    refreshInterval = intervalMS;
    refreshContent();
    updateRefreshIntervalDisplay();
  }

  if (parseInt(intervalMS) != 0) {
    var expires = new Date();
    expires.setTime(expires.getTime() + 1000 * 60 * 24 * 7);	// 1 year expiration on settings
    set_cookie("refreshInterval-" + (IsSummary ? "SUM" : "TARGET"), refreshInterval, expires);
  }

}

function updateRefreshIntervalDisplay() {
  // Iterate through all the <A> elements inside the refresh interval section and highlight the appropriate one
  // while deselecting the rest.
  var refreshIntervalDIV = document.getElementById("refreshInterval");

  if (refreshIntervalDIV) {
    var ATags = refreshIntervalDIV.getElementsByTagName("a");
    var matchVar;
    for (var i = 0; i < ATags.length; i++) {
      matchVar = ATags[i].href.match(/setRefreshInterval\(([-+]?\d*)\)/);
      if ((matchVar.length > 1) && (Number(matchVar[1]) == refreshInterval)) {
        ATags[i].className = "selectedRefreshInterval";
      } else {
        ATags[i].className = "";
      }
      // The "Auto" item shouldn't be visible on summary graphs.
      if ((matchVar.length > 1) && (Number(matchVar[1]) == -2)) {
        if (IsSummary) {
          ATags[i].style.display = "none";
        } else {
          ATags[i].style.display = "inline";
        }
      }
    }
  }
}

function restartRefreshTimer(timeTillNext) {
  // If it's running, queue up for the next update
  if (timeTillNext) {
    clearTimeout(refreshTimerID);
    refreshTimerID = setTimeout("refreshContent()", timeTillNext);
  } else {
    if ((targetFields) && ((targetFields["IsRunning"] != 0) || IsSummary)) {
      if ((refreshCount < 5) && (!IsSummary)) {
        clearTimeout(refreshTimerID);
        refreshTimerID = setTimeout("refreshContent()", 1500);
      } else {
        if (refreshInterval > 1000) {
          clearTimeout(refreshTimerID);
          refreshTimerID = setTimeout("refreshContent()", refreshInterval);
        } else {
          clearTimeout(refreshTimerID);
          // Is it set to "Auto" (or matching the trace interval)?
          if (refreshInterval == -2) {
            if (curTraceInterval > 1000) {
              refreshTimerID = setTimeout("refreshContent()", curTraceInterval);
            } else {
              refreshTimerID = setTimeout("refreshContent()", 1500);
            }
          } else if (refreshInterval == -1) {
            // Don't refresh at all!
          } else {
            refreshTimerID = setTimeout("refreshContent()", 1500);
          }
        }
      }
    }
  }
}

function displayError(ErrorMessage) {
  var ajaxerror = document.getElementById("ajaxerror");

  ajaxerror.style.display = "block";
  if (ajaxerror.innerHTML > "") {
    ajaxerror.innerHTML += "<hr>\n";
  } else {
    ajaxerror.innerHTML = "<center style=\"font-size:75%\">Double click the error messages to hide.</center>";
  }
  ajaxerror.innerHTML += "<div><span style=\"font-size:75%;float:right;margin-right:3px;\">" + Date() + "</span>" +
  ErrorMessage.replace(/(\r\n)/g, "<br/>") + "</div>\n";

  // If we have more than 10 errors, let's stop auto-refreshing
  if ((ajaxerror.childNodes.length > 20) && (refreshInterval != -1)) {
    refreshInterval = -1;
    updateRefreshIntervalDisplay();
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

// Convert the enter key to a "write to the server" and
// the escape key to "revert to server value"
function editControlKeyDown(currentControl, evt) {
  var r = '';
  var e = currentControl[0];

  if (evt.keyCode == 27) {
    if ((e.id != "") && (typeof origValue !== 'undefined') && (origValue)) {
      e.value = origValue;
      if (evt.stopPropagation && evt.preventDefault) {
        evt.stopPropagation();
        evt.preventDefault();
      }
      if (window.event) {
        window.event.cancelBubble = true;
        window.event.returnValue = false;
      }
    }
  }

  if ((evt.keyCode == 13) && (e.name != "target")) {
    // evt.keyCode = 9;
    if (evt.stopPropagation && evt.preventDefault) {
      evt.stopPropagation();
      evt.preventDefault();
    }
    if (window.event) {
      window.event.cancelBubble = true;
      window.event.returnValue = false;
    }
    // inputControlChanged(currentControl, evt);
  }
}


// Write the control's contents out to the application
// and turn on the fading checkmark.
function inputControlChange(changedControl, evt) {

  e = changedControl[0];
  if (e.id == "editTraceCount") {
    refreshContent({"TraceCount":e.value}, true);
  } else if (e.id == "selectTraceInterval") {
    refreshContent({"Interval": e.value}, true);
  } else if (e.id == "selectSummaryFocus") {
    refreshContent({"SummaryFocusPeriod": e.value}, true);
    $("#nonStandardFocus").setHTMLIfDifferent("");
  } else if (e.id == "editSamplesToInclude") {
    refreshContent({"SamplesToInclude": e.value}, true);
  } else if (e.id == "selectSettingsName") {
    refreshContent({"SettingsName": e.value}, true);
  } else if (e.id == "selectTimeGraphTime") {
    refreshContent({"TimeGraphTime": e.value}, true);
  }
  changedControl.css("background", "#8AFF8A url(images/check1.gif) no-repeat center right");
  setTimeout(function () {
    checktimer(changedControl, 0);
  }, 400);
}

// Fade out the checkmark on the field...
function checktimer(changedControl, ct) {

  if (ct != 4) {
    ct = ct + 1;
    if (ct == 2) {
      changedControl.css("background", "#FFFABE url(images/check" + ct + ".gif) no-repeat center right");
    } else if (ct == 3) {
      changedControl.css("background", "#FEF8B9 url(images/check" + ct + ".gif) no-repeat center right");
    } else if (ct == 4) {
      changedControl.css("background", "");
    }
    setTimeout(function () {
      checktimer(changedControl, ct);
    }, 100);
  }
}

function secondsToTime(aSeconds) {
  if (aSeconds < 120) {
    return aSeconds + " Seconds";
  } else if (aSeconds < 60 * 60 * 2) {
    return (aSeconds / 60) + " Minutes";
  } else {
    return (aSeconds / (60 * 60)) + " Hours";
  }
}