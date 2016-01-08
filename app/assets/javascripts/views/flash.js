define([ 'backbone' ], function(Backbone) {
  return Backbone.View.extend({
    el: $("#flash-messages"),

    events: {
      'click .flash-messages__message': 'hide'
    },

    template: null,

    render: function(additional_data) {
      return this;
    },

    hide: function(e) {
      this.$el.remove();
    }
  });
});