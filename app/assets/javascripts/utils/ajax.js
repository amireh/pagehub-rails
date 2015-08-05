define([ 'jquery' ], function($) {
  var ajax = $.ajax;

  return function(attrs) {
    return ajax({
      url: attrs.url,
      type: attrs.type,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      data: attrs.data
    }).then(null, function(xhrError) {
      xhrError.__pagehub_no_status = true;
      return xhrError;
    });
  };
});