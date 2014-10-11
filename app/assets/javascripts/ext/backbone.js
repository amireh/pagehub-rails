define(function(require) {
  var Backbone = require('backbone');
  var InflectionJS = require('inflection');
  var keys = Object.keys;

  Backbone.Model.prototype.toProps = function() {
    var attrs;

    attrs = this.toJSON();
    attrs.is_new = this.isNew();

    return keys(attrs).reduce(function(props, key) {
      props[key.camelize(true)] = attrs[key];
      return props;
    }, {});
  };

  return Backbone;
});