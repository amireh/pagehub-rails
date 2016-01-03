define([ 'jquery' ], function($) {
  return function(attrs) {
    return $.ajax({
      url: attrs.url,
      type: attrs.type,
      data: attrs.data
    }).then(null, function(xhrError) {
      xhrError.__pagehub_no_status = true;
      return xhrError;
    });
  };
});