define([ 'jquery', 'backbone', 'models/folder' ], function($, Backbone, Folder) {
  return Backbone.Collection.extend({
    defaults: {
      space: null
    },

    model: Folder,

    url: function() {
      this.space.get('links.folders')
    },

    parse: function(data) {
      if (data.folders) {
        return data.folders;
      }
      else {
        return data;
      }
    },

    initialize: function(models, options) {
      if (options) {
        console.warn('Deprecated: stop passing references in the options hash.');
      }
      // this.space = options.space;
    }

    // add: function(models, options) {
    //   var self = this;
    //   _.each(models, function(folder) { folder.space = self.space });

    //   return Backbone.Collection.prototype.add.apply(this, models, options);
    // }
  });
})