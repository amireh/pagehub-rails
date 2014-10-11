define([
  'backbone',
  'jquery',
  'hbs!templates/users/dashboard/space_record'
], function(Backbone, $, SpaceTmpl) {
  return Backbone.View.extend({
    el: $("#dashboard"),

    initialize: function(application) {
      this.$spaceListing = this.$el.find('#user_space_listing');
      this.$emptyListingMarker = this.$el.find('#no_spaces_marker');

      this.render(application.user.spaces);
      application.trigger('bootstrapped');
    },

    render: function(collection) {
      var $spaceListing = this.$spaceListing;
      this.$emptyListingMarker.toggle(collection.length === 0);

      collection.forEach(function(space) {
        var data  = space.toProps();

        if (space.get('role') == 'creator') {
          data.isOwner = true;
        }
        else if (space.get('role') != null) {
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