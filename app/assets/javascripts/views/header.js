define([
  'backbone',
  'hbs!templates/header_path',
  'jquery'
], function(Backbone, HeaderPath, $) {
  return window.PHLegacy.HeaderView = Backbone.View.extend({
    el: $("#header"),

    initialize: function(app) {
      this.state = app;

      if (app.space) { // editing a space?
        this.space      = app.space;
        this.user       = app.space.attributes.creator;

        this.space.on('sync', this.render, this);
      } else if (app.user) { // dashboard? profile?
        this.user = app.user;
      } else if (app.current_user) {
        this.user = app.current_user;
      }

      this.state.on('bootstrapped', this.render, this);
      this.state.on('highlight_nav_section', this.highlight, this);
    },

    render: function() {
      var data = {};

      if (this.user) {
        data.user = this.user.toProps ? this.user.toProps() : this.user;
      }

      if (this.space) {
        data.space = this.space.toProps();
      }

      this.$el.find('#path').html(HeaderPath(data));

      return this;
    },

    highlight: function(section) {
      this.$el.find('a#' + section + '_link').addClass('selected');
    }
  });
});