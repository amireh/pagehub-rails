window._ = require('lodash');
window.jQuery = require('jquery');

module.exports = require(
  'exports?Backbone!' +
  'imports?this=>window!' +
  'imports?exports=>undefined!' +
  'imports?module=>undefined!' +
  '../vendor/backbone-min'
);