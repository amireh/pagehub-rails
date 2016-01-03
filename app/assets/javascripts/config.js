define([ 'jquery', 'backbone', 'utils/ajax', 'jquery.tinysort' ], function($, Backbone, ajax) {
  Backbone.ajax = ajax;

  // jQuery TinySort
  $.tinysort.defaults.sortFunction = function(a,b) {
    var atext = a.e.text().trim(),
        btext = b.e.text().trim();

    return atext === btext ? 0 : (atext > btext ? 1 : -1);
  };

  return {};
});