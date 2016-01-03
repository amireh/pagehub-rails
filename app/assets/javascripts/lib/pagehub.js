define([
  'backbone',
  'underscore',
  'jquery',
  'hbs!templates/dialogs/connectivity_issue',
  'bootstrap',
  'shortcut',
  'jquery.ui',
  'canvas-loader'
], function(Backbone, _, $, ConnectivityIssueDlg) {
  var __init = false,
      timers = {
        flash: null,
        status: null
      },
      loader = null,
      loader_overlay = null;
      anime_dur = 250,
      status_shown = false,
      current_status = null,
      status_queue = [],
      animation_dur = 2500,
      pulses = {
        flash: 2.5
      },
      defaults = {
        status: 1
      };

  var StatusDelegate, DialogDelegate;
  var ApplicationView;
  var applicationViewSingleton;

  var showListFromEl = function(el) {
    if (el.parent("[disabled],:disabled,.disabled").length > 0)
      return false;

    hideList($("a.listlike.selected"));

    var list = el.nextAll("ol.listlike:first");

    list.css({ left: 0, right: 0 });

    if (list.width() + list.parent().offset().left >= $(window).width()) {
      list.css({ right: 0, left: -1 * list.width() });
    } else {
      list.css({ left: el.position().left, right: 0 });
    }

    list.show();

    el.addClass("selected");
    el.unbind('click', showList);
    el.add($(window)).bind('click', hideListCallback);

    return false;
  };

  var showList = function() {
    return showListFromEl($(this));
  };

  var hideListCallback = function(e) {
    e.preventDefault();

    hideList($(".listlike.selected:visible"));

    return false;
  };

  var dontHideList = false;

  var hideList = function(el) {
    if (dontHideList) {
      dontHideList = false;
      return true;
    }

    $(el).removeClass("selected");
    $(el).nextAll("ol.listlike:first").hide();
    $(el).add($(window)).unbind('click', hideListCallback);
    $(el).bind('click', showList);
  };

  ApplicationView = Backbone.View.extend({
    pbar_tick:  0,
    pbar_value: 0,
    loader: loader,

    initialize: function(application) {
      if (!application) {
        return this;
      }

      this.state = application;
    },

    dialog: {
      on_open: function(dlg) {

        dlg.focus();
        dlg.find('.ui-dialog-buttonpane button:last').focus();
        dlg.find('form').on('submit', function(e) { e.preventDefault(); return false; });
        dlg.keypress(function(e) {
          if ( e.keyCode == 13 ) {
            dlg.parent().find('.ui-dialog-buttonpane button:last').click();
            e.preventDefault();
            e.stopPropagation();
            return false;
          }
        });
      }
    },

    status: {
      clear: function(cb) {
        if (!$("#status").is(":visible"))
          return (cb || function() {})();

        $("#status").addClass("hidden").removeClass("visible");
        status_shown = false;

        if (cb)
          cb();

        if (status_queue.length > 0) {
          var __status = status_queue.pop();
          return this.status.show(__status[0], __status[1], __status[2]);
        }
      },

      show: function(text, status, seconds_to_show, no_escape) {
        if (!status)
          status = "notice";
        if (!seconds_to_show)
          seconds_to_show = defaults.status;

        // queue the status if there's one already being displayed
        // if (status_shown && current_status != "pending") {
        //   return status_queue.push([ text, status, seconds_to_show ]);
        // }

        // clear the status resetter timer
        if (timers.status)
          clearTimeout(timers.status)

        timers.status = setTimeout(function() {
          StatusDelegate.clear();
        }, status == "bad" ? animation_dur * 2 : animation_dur);
        $("#status").removeClass("pending good bad").addClass(status + " visible");

        if (no_escape)
          $("#status").html(text);
        else
          $("#status").text(text);

        status_shown = true;
        current_status = status;
      },

      mark_pending: function() {
        loader.show();

        // cl.show(); // Hidden by default
        // loader_overlay.show("fade");
      },

      mark_ready: function() {
        loader.hide();
        // loader_overlay.hide("fade");
      }
    },

    report_error: function(err_msg) {
      StatusDelegate.show("A script error has occured, please try to reproduce the bug and report it.", "bad");
      // console.log(err_msg);
      throw err_msg;
    }
  }); // ui

  $(document).ajaxStart(function(xhr) {
    StatusDelegate.mark_pending();
  });

  $(document).ajaxComplete(function(xhr)  {
    StatusDelegate.mark_ready();
  });

  $(document).ajaxError(function(xhr, xhrError) {
    var apiError;

    if (xhrError.__pagehub_no_status) {
      return true;
    }

    console.log(xhrError);

    try {
      apiError = JSON.parse(xhrError.responseText);
      StatusDelegate.show(apiError.messages.join('<br />'), "bad", null, true);
    } catch(exception) {
      // TODO: show some alert and report the error
      xhrError.exception = exception.message;

      $(ConnectivityIssueDlg(xhrError)).dialog({
        dialogClass: "alert-dialog",
        buttons: {
          Dismiss: function() {
            $(this).dialog('close');
          }
        }
      });
    }
  });

  // jQuery-UI Dialog
  $.extend($.ui.dialog.prototype.options, {
    modal: true,
    resizable: false,
    create: function(e, ui) {
      // $(this).dialog("widget").siblings('.ui-dialog').remove();
      $(this).dialog("widget").find('button').addClass('btn');
    },

    close: function() {
      $(this).remove();
    },

    open: function() {
      var $dialog = $(this);

      // Close all open dialogs.
      $(".ui-dialog-content:visible").not($dialog).dialog("close");

      DialogDelegate.on_open($dialog);
    }
  });

  // $(function() {
  var init = function() {
    if (__init) {
      return true;
    }

    $(document.body).tooltip({
      selector: '[rel=tooltip]',
      container: 'body',
      animation: false,
      placement: function(_, el) {
        return $(el).attr('data-placement') || 'bottom'
      }
    });

    $(document.body).popover({
      selector: '[rel=popover]',
      animation: false,
      trigger: 'hover',
      container: 'body',
      placement: function(_, el) {
        return $(el).attr('data-placement') || 'bottom'
      }
    });

    // loader = $(".loader");
    // loader_overlay = $(".loader-overlay");
    loader = new CanvasLoader('loader');
    loader.setColor('#595959'); // default is '#000000'
    loader.setShape('spiral'); // default is 'oval'
    loader.setDiameter(42); // default is 40
    loader.setDensity(18); // default is 40
    loader.setRange(1.1); // default is 1.3
    loader.setSpeed(1); // default is 2
    loader.setFPS(29); // default is 24

    // Togglable sections
    // $("section:not([data-untogglable])").
    //   find("> h1:first-child, > h2:first-child, > h3:first-child").
    //   addClass("togglable");

    // $("section > .togglable").click(function() {
    //   $(this).siblings(":not([data-untogglable])").toggle();
    //   $(this).toggleClass("toggled")
    // })

    // disable all links attributed with data-disabled
    $("a[data-disabled], a.disabled").click(function(e) {
      e.preventDefault();
      return false;
    });

    // "listlike" links
    $("a.listlike:not(.selected)").bind('click', showList);
    $("ol.listlike:not(.sticky) li:not(.sticky)").click(function() {
      var anchor = $(this).parent().prev("a.listlike");
      if (anchor.hasClass("selected")) {
        hideList(anchor);
      }

      return true; // let the event propagate
    });
    $("ol.listlike.sticky li, ol.listlike:not(.sticky) li.sticky").on('click', function(e) { dontHideList = true; return true; });

    __init = true;
  // });
  }();

  applicationViewSingleton = new ApplicationView();

  StatusDelegate = applicationViewSingleton.status;
  DialogDelegate = applicationViewSingleton.dialog;

  return applicationViewSingleton;
});
