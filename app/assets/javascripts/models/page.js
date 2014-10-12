define([ 'jquery', 'underscore', 'backbone', 'backbone.nested' ],
  function($, _, Backbone) {

  var Page = Backbone.DeepModel.extend({
    defaults: {
      title: ""
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
      if (this.isNew()) {
        return this.collection.url();
      }
      else {
        return this.get('url');
      }
    },

    initialize: function() {
      this.ctx      = {};
      this.urlRoot  = this.collection.space.get('links.pages');

      if (this.get('title').length === 0) {
        this.set('title', 'Untitled#' + this.cid.toString().replace('c', ''));
      }
    },

    getFolder: function() {
      if (this.collection) {
        return this.collection.folder;
      }
      // no collection means that we were just destroyed/removed so we're
      // assuming somebody (maybe our collection) had nicely kept a reference
      // to the folder for us before we were gibbed!
      //
      // Oh KVO, how I love.
      else {
        return this.folder;
      }
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