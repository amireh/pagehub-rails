define('models/user',
  [ 'backbone', 'collections/spaces' ],
  function(Backbone, Spaces) {

  var User = Backbone.DeepModel.extend({
    defaults: {
      nickname: "",
      email:    "",
      spaces:   null,
      preferences: {}
    },

    urlRoot: function() {
      return '/users';
    },

    parse: function(payload) {
      if (payload.hasOwnProperty('user')) {
        return payload.user;
      }
      else {
        return payload;
      }
    },

    initialize: function(data) {
      this.ctx = {};

      this.spaces = new Spaces(data.spaces || []);
      this.spaces.creator = this;
    }
  });

  return User;
});