define([ 'backbone', 'backbone.nested' ], function(Backbone) {
  var singleton;
  var State = Backbone.DeepModel.extend({
    initialize: function(data) {
      return _.implode(this, data || {});
    }
  });

  singleton = new State();

  return singleton;
});