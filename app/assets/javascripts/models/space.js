define([ 'jquery', 'underscore', 'ext/backbone', 'collections/folders' ],
  function($, _, Backbone, Folders) {
  var ajax = $.ajax;
  var Space = Backbone.DeepModel.extend({
    parse: function(payload) {
      if (payload.hasOwnProperty('space')) {
        return payload.space;
      }
      else {
        return payload;
      }
    },

    url: function() {
      return this.get('url');
    },

    initialize: function(data) {
      this.folders = new Folders(data.folders || [], {
        space: this,
        parse: true
      });
    },

    root_folder: function() {
      if (this.__root_folder) {
        return this.__root_folder;
      }

      this.__root_folder = this.folders.where({ parent: null })[0];

      return this.__root_folder;
    },

    modify_membership: function(user_id, role) {
      return ajax({
        url: this.get('links.memberships'),
        type: 'PATCH',
        dataType: 'json',
        contentType: 'json',
        processData: false,
        data: JSON.stringify({
          memberships: [{
            user_id: user_id,
            role: role
          }]
        })
      }).then(function(resp) {
        this.set(resp, { validate: false });
      }.bind(this));
    },

    is_admin: function(user) {
      var m = _.select(this.get('memberships'), function(m) { return parseInt(m.id) == parseInt(user.get('id')) })[0];
      return m && ['admin', 'creator'].indexOf(m.role) != -1;
    },

    find_page_by_fully_qualified_title: function(fqpt) {
      var folder = this.root_folder();
      var parts = fqpt.reverse();
      while (parts.length > 1) {
        var folder_title = parts.pop();

        folder = this.folders.where({ title: folder_title, 'parent.id': folder.get('id') })[0];

        if (!folder) {
          console.log("no such folder: " + folder_title);
          return null;
        }
      }

      return folder.pages.where({ title: parts[0] })[0];
    }
  });

  return Space;
});