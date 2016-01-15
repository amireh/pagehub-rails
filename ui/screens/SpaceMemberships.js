const React = require('react');
const { shape, arrayOf, } = React.PropTypes;
const { inflect } = require('inflection');
const ajax = require('../utils/ajax');
const { Typeahead } = require('react-typeahead');
const { debounce } = require('lodash');

const SpaceMemberships = React.createClass({
  propTypes: {
    space: shape({
      memberships: arrayOf(shape({

      }))
    })
  },

  getInitialState() {
    return {
      memberships: [],
      searchResults: []
    };
  },

  componentDidMount() {
    this.fetchMemberships();
    this.debouncedSearchForMembers = debounce(this.searchForMembers, 150);
  },

  render() {
    if (!this.state.memberships) {
      return <p>Loading...</p>;
    }

    return (
      <div className="space-memberships">
        <div>
          <h3>Add a member</h3>

          <Typeahead
            options={this.state.searchResults}
            placeholder="PageHub ID"
            onKeyUp={this.searchForMembers}
            filterOption="nickname"
            displayOption="nickname"
            onOptionSelected={this.inviteMember}
          />
        </div>

        <div>
          <table className="table table-striped">
            <thead>
              <tr>
                <th>Member</th>
                <th>Contributions</th>
                <th>Role<br /><small>(Member/Editor/Admin)</small></th>
                <th>Actions</th>
              </tr>
            </thead>

            <tbody>
              {this.state.memberships.map(this.renderRecord)}
            </tbody>
          </table>
        </div>

        <section className="well space-memberships__role-description">
          <h3>Space Member Roles</h3>
          <hr />
          <div className="column">
            <h4>Members</h4>
            <p>Members are limited to reading the pages written by the space editors.</p>
          </div>

          <div className="column">
            <h4>Editors</h4>
            <p>Editors can write new pages and folders, edit existing ones, and rename them.</p>
          </div>

          <div className="column">
            <h4>Admins</h4>
            <p>Administrators can invite new members,
              promote and demote them to and from
              the editorial role, and can kick non-admins.</p>
            <p>
              Admins get all the perks editors and members do.
            </p>
          </div>

          <div className="column">
            <h4>Space creator</h4>
            <p>The space creator can change the space name, promote
              and demote others to/from the admin role, and kick admins.
            </p>
          </div>
        </section>
      </div>
    );
  },

  renderRecord(record) {
    const userId = record.user_id;
    const pageCount = this.props.space.pages.filter(p => p.user_id === userId).length;
    const { role } = record;
    const canKick = record.user_id !== this.props.space.creator.id;

    return (
      <tr key={record.user_id} className="space-memberships__record">
        <td>
          <img
            className="space-memberships__record-avatar"
            src={record.gravatar}
          /> {record.user_nickname}
        </td>
        <td>
          <span>{pageCount} {inflect('page', pageCount)}</span>
        </td>

        <td>
          <label>
            <input
              type="radio"
              value="member"
              onChange={this.changeMemberRole.bind(null, userId)}
              checked={role === 'member'}
            /> M
          </label>

          {' '}

          <label>
            <input
              type="radio"
              value="editor"
              onChange={this.changeMemberRole.bind(null, userId)}
              checked={role === 'editor'}
            /> E
          </label>

          {' '}

          <label>
            <input
              type="radio"
              value="admin"
              onChange={this.changeMemberRole.bind(null, userId)}
              checked={['admin', 'creator'].indexOf(role) > -1}
            /> A
          </label>
        </td>

        <td>
          {canKick && (
            <button
              className="btn btn-mini btn-danger"
              onClick={this.kick.bind(null, userId)}
            >
              Uninvite
            </button>
          )}
        </td>
      </tr>
    );
  },

  fetchMemberships() {
    ajax({
      url: `/api/spaces/${this.props.space.id}/memberships`
    }).then((payload) => {
      this.setState({ memberships: payload.memberships })
    });
  },

  changeMemberRole(userId, e) {
    const spaceId = this.props.space.id;

    ajax({
      url: `/api/spaces/${spaceId}/memberships/${userId}`,
      type: 'PATCH',
      data: JSON.stringify({
        membership: {
          role: e.target.value
        }
      })
    }).then(this.fetchMemberships);
  },

  kick(userId) {
    const spaceId = this.props.space.id;

    if (!window.confirm(
      "Uninviting this member from the space will prevent them from all " +
      "access.\n\nAre you sure you want to do this?"
      )
    ) {
      return;
    }

    ajax({
      url: `/api/spaces/${spaceId}/memberships/${userId}`,
      type: 'DELETE'
    }).then(this.fetchMemberships);
  },

  searchForMembers(e) {
    const term = e.target.value;
    console.log('term:', term);

    ajax({
      url: '/api/users/search',
      data: {
        nickname: term
      }
    }).then(({users}) => {
      this.setState({ searchResults: users })
    });
  },

  inviteMember(searchResult) {
    const spaceId = this.props.space.id;
    const userId = searchResult.id;

    ajax({
      url: `/api/spaces/${spaceId}/memberships/${userId}`,
      type: 'POST',
      data: JSON.stringify({
        membership: {
          role: 'member'
        }
      })
    }).then(this.fetchMemberships)
  }
});

module.exports = SpaceMemberships;
