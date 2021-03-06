const SettingView = require('views/shared/settings/setting_view');
const $ = require('jquery');
const UI = require('pagehub');
const SpaceMemberships = require('../../../../../../ui/screens/SpaceMemberships');
const React = require('react');
const ReactDOM = require('react-dom');

// define([ , 'jquery', 'pagehub', , 'utils/ajax' ],
// function(SettingView, $, UI, MembershipRecordTmpl, ajax) {

module.exports = SettingView.extend({
  el: $("#space_membership_settings"),

  render() {
    this.$el.show();

    ReactDOM.render(<SpaceMemberships space={ENV.space} />, this.$el[0]);
  },

  hide() {
    ReactDOM.unmountComponentAtNode(this.$el[0]);
  },

  // events: {
  //   // 'keyup #user_search':       'queue_user_lookup',
  //   'click #force_user_search': 'force_user_search',
  //   'click button':             'consume',
  //   // 'click #user_listing li':   'add_user',
  //   'click [data-action=kick]': 'kick_user',
  //   'change #membership_records input[type=radio][name^=users]': 'rankify'
  // },

  // templates: {
  //   record: MembershipRecordTmpl
  // },

  // initialize: function(data) {
  //   SettingView.prototype.initialize.apply(this, arguments);
  //   this._ctx   = {};

  //   this.lookup_timer = null;
  //   this.lookup_pulse = 250;

  //   this.elements = {
  //     user_search:        this.$el.find('#user_search'),
  //     user_listing:       this.$el.find('#user_listing'),
  //     membership_records: this.$el.find('#membership_records')
  //   }

  //   this.unserializable = true;

  //   this.bootstrap();
  // },

  // force_user_search: function() {
  //   this.elements.user_search.autocomplete("search");
  //   return this;
  // },

  // bootstrap: function() {
  //   var view = this;

  //   this.elements.user_search.autocomplete({
  //     delay:    this.lookup_pulse,
  //     appendTo: this.elements.user_listing,
  //     focus: function(e) { e.preventDefault(); return false },
  //     // select:   this.add_user,
  //     source: function(request, handler) {
  //       ajax({
  //         url: "/api/v1/users/search",
  //         data: { nickname: request.term },
  //       }).then(function(payload) {
  //         var users = payload.users;
  //         view._ctx.users = users;

  //         handler(users.map(function(u) {
  //           return { label: u.nickname, value: u.id, icon: u.gravatar }
  //         }));
  //       });
  //     }
  //   }).data( "ui-autocomplete" )._renderItem = function( ul, item ) {
  //     return $( "<li>" )
  //       .append( "<a><img src=\"" + item.icon + "\" /> " + item.label + "</a>" )
  //       .appendTo( ul );
  //   };

  //   this.elements.user_search.on('autocompleteselect', view, view.add_user);

  //   return this.space.get('memberships').every(function(user) {
  //     return this.add_record(user);
  //   }, this);
  // },

  // membership_from_id: function(id) {
  //   return _.select(this.space.get('memberships'), function(m) { return m.user_id == id; })[0];
  // },
  // membership_from_nickname: function(id) {
  //   return _.select(this.space.get('memberships'), function(m) { return m.nickname == id; })[0];
  // },

  // membership_from_record: function(el) {
  //   var user_id = el.parents('tr[id]:first').attr("id").replace('user_', '');
  //   return this.membership_from_id(user_id);
  // },

  // add_record: function(membership, selector) {
  //   var data = membership;
  //       data.can_kick = membership.user_id != this.space.get('creator.id');
  //   var tmpl = MembershipRecordTmpl(data);

  //   if (selector) {
  //     selector.replaceWith(tmpl);
  //   } else {
  //     this.elements.membership_records.append(tmpl);
  //   }

  //   return this;
  // },

  // rankify: function(e) {
  //   var el          = $(e.target),
  //       membership  = this.membership_from_record(el),
  //       role        = el.val(),
  //       view        = this;

  //   ajax({
  //     url: this.space.get('links.memberships'),
  //     type: 'PATCH',
  //     data: JSON.stringify({
  //       memberships: [{
  //         user_id: membership.user_id,
  //         role:    role
  //       }]
  //     })
  //   }).then(function() {
  //     UI.status.show(membership.nickname + " is now a " + role.vowelize() + " of this space.", "good");
  //   }, function() {
  //     view.add_record(membership, el.parents("tr:first"));
  //     // el.parents("tr:first").replaceWith(MembershipRecordTmpl(membership))
  //     // el.attr("checked", null);
  //     // el.parents("td:first").find("[value=" + membership.role + "]").attr("checked", true);
  //   });

  //   e.preventDefault();
  //   return false;
  // },

  // consume: function(e) {
  //   e.preventDefault();
  //   return false;
  // },

  // serialize: function() {
  //   return {}
  // },

  // add_user: function(e, ui) {
  //   var el            = $(e.target),
  //       user_id       = ui.item.value,
  //       user_nn       = ui.item.label,
  //       user_avatar   = ui.item.icon;
  //       view          = e.data,
  //       m             = view.membership_from_id(user_id);

  //   view.elements.user_search.val(ui.item.label);

  //   e.preventDefault();

  //   if (m) {
  //     UI.status.show(m.nickname + " is already a member!", "bad");
  //     return true;
  //   }

  //   view.trigger('sync', {
  //      memberships: [{
  //       user_id: user_id,
  //       role:    'member'
  //     }]
  //   }, {
  //     success: function() {
  //       UI.status.show(user_nn + " is now a member of this space.", "good");
  //       view.add_record(view.membership_from_id(user_id));
  //     }
  //   })

  //   return true;
  // },

  // kick_user: function(e) {
  //   var el    = $(e.target),
  //       m     = this.membership_from_record(el),
  //       view  = this;

  //   view.trigger('sync', {
  //     memberships: [{
  //       user_id: m.user_id,
  //       role:    null
  //     }]
  //   }, {
  //     success: function() {
  //       view.elements.membership_records.find('#user_' + m.user_id).remove();
  //       UI.status.show( m.nickname + " is no longer a member of this space.", "good");

  //       // this is leaking for some reason
  //       $("body > .tooltip:last").remove();
  //     }
  //   });
  // }
});