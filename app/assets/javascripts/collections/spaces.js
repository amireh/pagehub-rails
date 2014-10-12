define([ 'jquery', 'backbone', 'models/space' ], function($, Backbone, Space) {
  return Backbone.Collection.extend({
    defaults: {
    },

    model: Space,

    url: function() {
      this.user.get('links.spaces');
    },

    parse: function(data) {
      if (data.spaces) {
        return data.spaces;
      }
      else {
        return data;
      }
    }
  });
})