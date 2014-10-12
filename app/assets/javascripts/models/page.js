define([ 'jquery', 'underscore', 'backbone', 'backbone.nested' ],
  function($, _, Backbone) {

  var Page = Backbone.DeepModel.extend({
    defaults: {
      title:        "",
    //   pretty_title: "",
    //   content:      "",
    //   creator:      null,
    //   revisions:    []
    },

    parse: function(payload) {
      if (payload.hasOwnProperty('page')) {
        return payload.page;
      }
      else {
        return payload;
      }
    },

    url: function() {
      return this.get('url');
    },

    initialize: function() {
      this.ctx      = {};
      this.urlRoot  = this.collection.space.get('links.pages');

      if (this.get('title').length === 0) {
        this.set('title', 'Untitled#' + this.cid.toString().replace('c', ''));
      }

      this.on('change:folder_id', this.set_folder, this);
      // this.collection.on('add', this.set_folder, this);
    },

    getFolder: function() {
      return this.collection.folder;
    },

    set_folder: function() {
      console.warn('Deprecated');
    },

    getPath: function() {
      var parts = this.collection.folder.getPath().split('/');
      parts.push(this.get('pretty_title'));
      return parts.join('/');
    },

    fully_qualified_title: function() {
      var parts =
        _.reject(
          _.collect(this.collection.folder.ancestors(),
                    function(f) { return f.get('title'); }),
          function(t) { return t == 'None' })
        .reverse();

      parts.push(this.get('title'));

      return parts;
    }
  });

  return Page;
});