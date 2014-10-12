define([
  'hbs!templates/header_path'
], function(HeaderPath) {
  return Backbone.View.extend({
    el: $("#header"),

    initialize: function(app) {
      this.state = app;

      if (app.space) { // editing a space?
        this.space      = app.space;
        this.user       = app.space.getCreator();

        this.space.on('sync', this.render, this);
      } else if (app.user) { // dashboard? profile?
        this.user = app.user;
      } else {
        if (app.current_user) {
          this.user = app.current_user;
        }
      }

      if (this.user && app.current_user == app.user) { // current user sections
        this.user.on('change:nickname', this.render, this);
        this.user.on('sync', this.render, this);
      }

      this.state.on('bootstrapped', this.render, this);
      this.state.on('highlight_nav_section', this.highlight, this);
    },

    render: function() {
      var data = {};

      if (this.user) {
        data.user = this.user.toProps();
      }

      if (this.space) {
        data.space = this.space.toProps();
        data.space_admin = this.space.is_admin(this.state.current_user);
      }

      this.$el.find('#path').html(HeaderPath(data));

      return this;
    },

    highlight: function(section) {
      this.$el.find('a#' + section + '_link').addClass('selected');
    }
  });
});