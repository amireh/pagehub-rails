define([
  'backbone',
  'jquery',
  'hbs!templates/users/dashboard/space_record'
], function(Backbone, $, SpaceTmpl) {
  return Backbone.View.extend({
    el: $("#dashboard"),

    currentUserId: null,

    initialize: function(application) {
      this.$spaceListing = this.$el.find('#user_space_listing');
      this.$emptyListingMarker = this.$el.find('#no_spaces_marker');

      this.render(application.user.spaces);
      application.trigger('bootstrapped');

      this.currentUserId = application.user.get('id');
    },

    render: function(collection) {
      var $spaceListing = this.$spaceListing;
      var currentUserId = this.currentUserId;

      this.$emptyListingMarker.toggle(collection.length === 0);

      collection.forEach(function(space) {
        var role;
        var data  = space.toProps();
        var membership = data.memberships.filter(function(membership) {
          return membership.userId === currentUserId;
        })[0] || {};

        role = membership.role;

        if (role === 'creator') {
          data.isOwner = true;
        }
        else if (role !== null) {
          data.isMember = true;
        }
        else {
          data.isGuest  = true;
        }

        if (data.brief.length === 0) {
          data.brief = null;
        }

        $spaceListing.append(SpaceTmpl(data));
      });
    }
  });
})