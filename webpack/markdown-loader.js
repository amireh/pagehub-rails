var marked = require('marked');

module.exports = function(source) {
  this.cacheable();

  return marked(source);
};