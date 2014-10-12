define(function(require) {
  var application = require('pagehub.state');
  var UI = require('pagehub');
  var Flash = require('views/flash');
  var User = require('models/user');
  var Space = require('models/space');
  var global = this;
  var ENV = this.ENV;

  if (ENV.DEBUG) {
    global.App = application;
  }

  if (ENV.hasOwnProperty('app_preferences')) {
    application.set('preferences', ENV.app_preferences.app);
  }

  application.on('bootstrapped', function() {
    application._bootstrapped = true;
  });

  application.Flash = new Flash(application);
  application.UI = UI;
  application.UI.initialize(application);

  if (ENV.current_user) {
    application.current_user = new User(ENV.current_user, { parse: true });
  }

  if (ENV.user) {
    if (ENV.user === ENV.current_user) {
      application.user = application.current_user;
    }
    else {
      application.user = new User(ENV.user, { parse: true });
    }
  }

  (function exposeSpace() {
    var creator;

    if (ENV.space) {
      if (ENV.space_creator === ENV.user) {
        creator = application.user;
      }
      else if (ENV.space_creator === ENV.current_user) {
        creator = application.current_user;
      }
      else {
        creator = new User(ENV.space_creator, { parse: true });
      }

      application.space = new Space(ENV.space, { parse: true });
      application.space.creator = creator;
    }
  }());

  application.trigger('ready');
});