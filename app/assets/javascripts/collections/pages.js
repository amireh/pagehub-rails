define([ 'backbone', 'models/page' ], function(Backbone, Page) {
  return Backbone.Collection.extend({
    model: Page,

    url: function() {
      return this.folder.get('links.pages');
    },

    comparator: function(model) {
      return model.get('title');
    },

    initialize: function(models, data) {
      this.on('add', this.configurePath, this);
      this.on('change:folder_id', this.configurePath, this);
    },

    configureWithFolder: function(folder) {
      this.space = folder.collection.space;
      this.folder = folder;
      this.folder.on('change:folder_id', this.configurePagePaths, this);

      this.on('remove', function(page) {
        page.folder = this.folder;
      }.bind(this));
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