define([ 'underscore', 'backbone', 'backbone.nested' ], function(_, Backbone) {
  var singleton;
  var State = Backbone.DeepModel.extend({
    initialize: function(data) {
      return _.extend(this, data || {});
    }
  });

  singleton = new State();

  return singleton;
});