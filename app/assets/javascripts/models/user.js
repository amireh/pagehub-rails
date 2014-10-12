define([ 'backbone', 'collections/spaces' ], function(Backbone, Spaces) {
  var User = Backbone.DeepModel.extend({
    defaults: {
      nickname: "",
      email:    "",
      spaces:   null,
      preferences: {}
    },

    urlRoot: function() {
      return '/api/v1/users';
    },

    url: function() {
      return this.get('url');
    },

    parse: function(payload) {
      var data;

      if (payload.hasOwnProperty('user')) {
        data = payload.user;
      }
      else {
        data = payload;
      }

      if (data) {
        if (data.spaces) {
          this.spaces = this.spaces || new Spaces();
          this.spaces.reset(data.spaces, { parse: true });
          this.spaces.creator = this;
        }
      }

      return data;
    },

    initialize: function(data) {
      this.ctx = {};

      if (!this.spaces) {
        this.spaces = new Spaces(data.spaces || [], { parse: true });
        this.spaces.creator = this;
      }
    }
  });

  return User;
});