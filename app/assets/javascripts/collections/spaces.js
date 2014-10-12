define([ 'jquery', 'backbone', 'models/space' ], function($, Backbone, Space) {
  return Backbone.Collection.extend({
    defaults: {
    },

    model: Space,

    url:   function() {
      this.creator.get('media').spaces_url
    },

    parse: function(data) {
      if (data.spaces) {
        return data.spaces;
      }
      else {
        return data;
      }
    },

    initialize: function() {
      this.creator = null;
    }
  });
})