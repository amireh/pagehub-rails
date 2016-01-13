require("../app/assets/javascripts/vendor/handlebars");

var Handlebars = global.Handlebars;

module.exports = function(source) {
  this.cacheable();

  // var name = this.resourcePath
  //   .replace(/(.+)\/app\/assets\/javascripts\//, '')
  //   .replace(/\.hbs$/, '')
  //   .replace(/_/g, '-')
  // ;
  var ast = Handlebars.precompile(source);
  // var template = Handlebars.precompile(ast).toString();
  return ast;
  // return template;
  // return "Ember.TEMPLATES[\""+name+"\"] = Ember.Handlebars.template("+template+");";
};

