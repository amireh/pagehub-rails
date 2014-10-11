define([ 'jquery', 'backbone', 'models/folder' ], function($, Backbone, Folder) {
  return Backbone.Collection.extend({
    defaults: {
      space: null
    },

    model: Folder,

    url: function() {
      this.space.get('media.folders_url')
    },

    parse: function(data) {
      return data.folders;
    },

    initialize: function(models, data) {
      _.extend(this, data);

    }

    // add: function(models, options) {
    //   var self = this;
    //   _.each(models, function(folder) { folder.space = self.space });

    //   return Backbone.Collection.prototype.add.apply(this, models, options);
    // }
  });
})