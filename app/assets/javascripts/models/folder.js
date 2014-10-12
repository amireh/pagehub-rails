define([
  'jquery',
  'underscore',
  'backbone',
  'collections/pages',
  'backbone.nested'
], function($, _, Backbone, Pages) {
  var Folder = Backbone.DeepModel.extend({
    initialize: function(data) {
      this.ctx      = {};
      this.urlRoot  = this.collection.space.get('media.folders.url');

      this.pages = new Pages(null, { folder: this, space: this.collection.space });
      this.pages.reset(data.pages);

      this.on('change:folder_id', this.configure_path, this);
      this.on('change:title', this.configure_path, this);
    },

    configure_path: function() {
      this.set('path', this.path());

      _.each(this.children(), function(f) {
        return f.configure_path();
      });

      return this;
    },

    has_parent: function() {
      return !!(this.get('folder_id'))
    },

    get_parent: function() {
      return this.collection.get(this.get('folder_id'));
    },

    ancestors: function() {
      var ancestors = [ this ];

      if (this.has_parent()) {
        ancestors.push( this.get_parent().ancestors() );
      }

      return _.uniq(_.flatten(ancestors)).filter(function(folder) {
        return !!folder;
      });
    },

    children: function() {
      return this.collection.where({ 'folder_id': this.get('id') });
    },

    parse: function(data) {
      if (data.folder) {
        return data.folder;
      }
      else {
        return data;
      }
    },

    path: function() {
      var parts = _.
        reject(_.collect(this.ancestors(), function(f) {
          return f.get('pretty_title');
        }), function(t) {
          return t == 'none';
        }).reverse();

      // parts.push(this.get('pretty_title'));

      return parts.join('/');
    },

  });

  return Folder;
});