define([ 'jquery' ], function($) {
  return function(formEl) {
    return $(formEl).
      serializeArray().
      reduce(function(hsh, item) {
        hsh[item.name] = item.value;
        return hsh;
      }, {})
    ;
  }
});