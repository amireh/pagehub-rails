define([ 'jquery', 'jquery.tinysort' ], function($) {
  var csrfToken;

  $.ajaxSetup({
    headers: {
      'Accept': "application/json; charset=utf-8",
      'Content-Type': "application/json; charset=utf-8"
    }
  });

  $.ajaxSetup({
    beforeSend: function (xhr) {
      xhr.setRequestHeader('X-CSRF-Token', csrfToken);
    }
  });

  // jQuery TinySort
  $.tinysort.defaults.sortFunction = function(a,b) {
    var atext = a.e.text().trim(),
        btext = b.e.text().trim();

    return atext === btext ? 0 : (atext > btext ? 1 : -1);
  };

  $(function() {
    csrfToken = $('meta[name="csrf-token"]').attr('content');
  });

  return {};
});