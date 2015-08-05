define(function() {
  var APIError = function(xhrError) {
    var jsonError;

    try {
      jsonError = xhrError.responseJSON || JSON.parse(xhrError.responseText);
    }
    catch(e) {
      jsonError = {
        status: 'error',
        messages: [ e.responseText ],
        field_errors: {}
      };
    }

    return jsonError;
  };

  return APIError;
});