define([ 'backbone' ], function(Backbone) {
  return Backbone.View.extend({
    el: $("#flash-messages"),

    events: {
      'click .flash': 'hide'
    },

    template: null,

    render: function(additional_data) {
      return this;
    },

    hide: function(e) {
      var $flash = $(e.target).closest('.flash');

      $flash.animate({ right: -500 }, 400, 'linear').promise().then(function() {
        $flash.remove();
      });
    }
  });
});