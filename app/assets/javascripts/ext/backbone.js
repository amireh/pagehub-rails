define(function(require) {
  var Backbone = require('backbone');
  var camelize = require('inflection').camelize;
  var keys = Object.keys;

  Backbone.Model.prototype.toProps = function() {
    var attrs;

    attrs = this.toJSON();
    attrs.is_new = this.isNew();

    return keys(attrs).reduce(function(props, key) {
      props[camelize(key, true)] = attrs[key];
      return props;
    }, {});
  };

  return Backbone;
});