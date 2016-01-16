const React = require('react');
const { string, shape } = React.PropTypes;
const ajax = require('../utils/ajax');
const Dialog = require('./Dialog');
const { compose } = require('lodash');

const CreateFolderDialog = React.createClass({
  propTypes: {
    folder: shape({
      id: string,
      title: string,
      folder_id: string
    }),

    spaceId: string.isRequired
  },

  getInitialState() {
    return {
      folders: []
    };
  },

  getDefaultProps() {
    return {
      folder: {},
    };
  },

  componentDidMount() {
    const { spaceId } = this.props;

    ajax({ url: `/api/spaces/${spaceId}/folders` }).then(payload => {
      this.setState({ folders: payload.folders });
    });
  },

  render() {
    const { folder } = this.props;

    return (
      <Dialog ref="dialog" onClose={this.props.onClose}>
        <form onSubmit={this.save}>
          <label>
            Folder title

            <div>
              <input autoFocus type="text" ref="title" defaultValue={folder.title} />
            </div>
          </label>

          <label>
            Parent folder

            <div>
              <select ref="folderId" defaultValue={folder.folder_id}>
                {this.state.folders.map(this.renderFolderOption)}
              </select>
            </div>
          </label>

          <div>
            <button
              type="submit"
              className="btn btn-primary"
              onClick={this.save}
            >
              Save
            </button>
          </div>
        </form>
      </Dialog>
    );
  },

  renderFolderOption(folder) {
    return (
      <option key={folder.id} value={folder.id}>
        {folder.title}
      </option>
    );
  },

  save(e) {
    e.preventDefault();

    const data = {
      folder: {
        title: this.refs.title.value,
        folder_id: this.refs.folderId.value
      }
    };

    const done = compose(this.close, this.commit);

    if (this.props.folder.id) {
      ajax({
        url: `/api/spaces/${this.props.spaceId}/folders/${this.props.folder.id}`,
        type: 'PATCH',
        data: JSON.stringify(data)
      }).then(done);
    }
    else {
      ajax({
        url: `/api/spaces/${this.props.spaceId}/folders`,
        type: 'POST',
        data: JSON.stringify(data)
      }).then(done);
    }
  },

  close() {
    this.props.onClose();
  },

  commit(payload) {
    if (this.props.onCommit) {
      this.props.onCommit(payload.folders[0]);
    }
  }
});

module.exports = CreateFolderDialog;
