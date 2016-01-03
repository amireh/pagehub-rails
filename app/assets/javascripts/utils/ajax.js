define([ 'jquery', 'underscore' ], function($, _) {
  return function(attrs) {
    return $.ajax(_.extend({}, attrs, {
      headers: _.extend({}, {
        'Accept': "application/json; charset=utf-8",
        'Content-Type': "application/json; charset=utf-8",
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content'),
      }, attrs.headers),
    })).then(null, function(xhrError) {
      xhrError.__pagehub_no_status = true;
      return xhrError;
    });
  };
});