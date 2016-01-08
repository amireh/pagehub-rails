define([ 'underscore', 'ext/backbone', 'collections/folders', 'utils/ajax' ],
  function(_, Backbone, Folders, ajax) {
  var groupBy = _.groupBy;

  var Space = Backbone.DeepModel.extend({
    parse: function(payload) {
      var data;

      if (payload.hasOwnProperty('space')) {
        data = payload.space;
      }
      else {
        data = payload;
      }

      data = _.extend({}, data);

      if (data.memberships) {
        data.nr_pages = data.memberships.reduce(function(sum, membership) {
          return sum += membership.page_count || 0;
        }, 0);

        data.nr_members = data.memberships.length;
      }

      if (data.folders) {
        console.log('Parsing folders:', data.id, data.title, data.folders.length);
        this.parseFolders(data.folders);
      }

      if (data.pages) {
        var folderPages = groupBy(data.pages, 'folder_id');
        var folders = this.folders;

        Object.keys(folderPages).forEach(function(folderId) {
          var folder = folders.get(folderId);

          if (folder) {
            folder.pages.reset([].slice.call(folderPages[folderId]), {
              parse: true,
              validate: false,
              silent: true
            });
          }
        }.bind(this));

        delete data.pages;
      }

      return data;
    },

    url: function() {
      return this.get('url');
    },

    root_folder: function() {
      if (this.__root_folder) {
        return this.__root_folder;
      }

      this.__root_folder = this.folders.where({ folder_id: '' })[0];

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

    is_admin: function(userId) {
      var m = this.get('memberships').filter(function(m) {
        return m.user_id === userId
      })[0];

      if (!m) {
        return false;
      }

      return ['admin', 'creator'].indexOf(m.role) > -1;
    },

    find_page_by_fully_qualified_title: function(fqpt) {
      var folder = this.root_folder();
      var parts = fqpt.reverse();

      while (parts.length > 1) {
        var folder_title = parts.pop();

        folder = this.folders.where({
          title: folder_title,
          folder_id: folder.get('id')
        })[0];

        if (!folder) {
          console.log("no such folder: " + folder_title);
          return null;
        }
      }

      return folder.pages.where({ title: parts[0] })[0];
    },

    parseFolders: function(data) {
      if (!this.folders) {
        this.folders = new Folders();
        this.folders.space = this;
      }

      this.folders.reset(data, { parse: true });
    },

    getCreator: function() {
      return this.collection.user;
    }
  });

  return Space;
});