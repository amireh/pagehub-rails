define([
  'jquery',
  'underscore',
  'backbone',
  'utils/ajax',
  'collections/pages',
  'backbone.nested',
], function($, _, Backbone, ajax, Pages) {
  var Folder = Backbone.DeepModel.extend({
    initialize: function(data) {
      this.ctx      = {};
      this.urlRoot  = this.collection.space.get('links.folders');

      this.pages = new Pages();
      this.pages.configureWithFolder(this);

      this.on('change:folder_id', this.configurePath, this);
      this.on('change:title', this.configurePath, this);
    },

    url: function() {
      if (this.isNew()) {
        return this.collection.url();
      }
      else {
        return this.get('url');
      }
    },

    configurePath: function() {
      this.set('path', this.getPath());

      _.each(this.children(), function(subFolder) {
        return subFolder.configurePath();
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

    save: function(attrs) {
      if (this.isNew()) {
        return Backbone.Model.prototype.save.apply(this, arguments);
      }

      return ajax({
        url: this.get('url'),
        type: 'PATCH',
        data: JSON.stringify({
          folder: attrs
        })
      });
    },

    getPath: function() {
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