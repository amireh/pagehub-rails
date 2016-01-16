const $ = require('jquery');
const Backbone = require('backbone');
const Folder = require('models/folder');
const UI = require('pagehub');
const Shortcut = require('shortcut');
const ajax = require('utils/ajax');
const CreateFolderDialog = require('pagehub-ui/components/CreateFolderDialog');
const React = require('react');
const ReactDOM = require('react-dom');

module.exports = Backbone.View.extend({
    el: $("#resource_actions"),

    events: {
      'click #new_page':    'create_page',
      'click #new_folder':  'create_folder',
      'click #download_zip': 'download_space'
    },

    initialize: function(data) {
      var view = this;

      _.extend(this, data);

      this.$el.find('#new_page').attr("href", this.space.get('links.new_page'));

      Shortcut.add("ctrl+alt+c", this.create_page.bind(this));
      Shortcut.add("ctrl+alt+f", this.create_folder.bind(this));
    },

    consume: function(e) {
      e.preventDefault();
      return false;
    },

    create_page: function(e) {
      if (e) { e.preventDefault(); }

      const workspace = this.workspace;
      const folder  = workspace.current_folder || this.space.root_folder();
      const folderId = folder.get('id');

      ajax({
        url: `/api/folders/${folderId}/pages`,
        type: 'POST',
        data: JSON.stringify({ page: {} })
      }).then(function(payload) {
        const page = folder.pages.add(payload.pages[0]);

        workspace.trigger('load_page', page);

        UI.status.show("Created!", "good");
      });

      return false;
    },

    create_folder: function(e) {
      if (e) { e.preventDefault(); }

      const { space } = this;
      const container = document.querySelector('#app__dialog');
      const cleanup = () => {
        ReactDOM.unmountComponentAtNode(container);
      };

      const storeFolder = (props) => {
        space.folders.add(props);
      };

      ReactDOM.render(
        <CreateFolderDialog
          spaceId={space.get('id')}
          onClose={cleanup}
          onCommit={storeFolder}
        />,

        container
      );
    },

    download_space: function(e) {
      UI.status.show('Please wait while we create the ZIP archive for you.', 'good');

      return true;
    }
  });