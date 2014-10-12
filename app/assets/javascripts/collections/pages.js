define([ 'backbone', 'models/page' ], function(Backbone, Page) {
  return Backbone.Collection.extend({
    model: Page,

    initialize: function(models, data) {
      this.on('add', this.configurePath, this);
      this.on('change:folder_id', this.configurePath, this);
    },

    configureWithFolder: function(folder) {
      this.space = folder.collection.space;
      this.folder = folder;
      this.folder.on('change:folder_id', this.configurePagePaths, this);
    },

    configurePath: function(page) {
      page.set('path', page.getPath());

      return this;
    },

    configurePagePaths: function() {
      this.every(function(p) {
        return this.configurePath(p);
      }, this);

      return this;
    },
  });
})