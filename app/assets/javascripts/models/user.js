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

      if (data.spaces) {
        this.parseSpaces(data.spaces);
        delete data.spaces;
      }

      return data;
    },

    initialize: function(data) {
      this.ctx = {};
      this.parseSpaces();
    },

    parseSpaces: function(data) {
      if (!this.spaces) {
        this.spaces = new Spaces(null);
        this.spaces.user = this;
      }

      if (data) {
        this.spaces.reset(data, { parse: true, validate: false });
      }
    }
  });

  return User;
});