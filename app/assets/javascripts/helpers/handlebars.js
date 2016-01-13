define([ 'underscore', 'handlebars/runtime', 'md5' ], function(_, Handlebars, md5) {
  Handlebars.registerHelper("pluralize", function (word, count) {
    return [count, word].join(' ');
    // return _(word).pluralize(count, true);
  });

  Handlebars.registerHelper('escape', function(word) {
    return _.escape(word);
  });

  Handlebars.registerHelper('h', function(word) {
    return _.escape(word);
  });

  Handlebars.registerHelper('checkify', function(attribute, values) {
    if (_.indexOf(values.split(' '), attribute) != -1) return 'checked="checked"';
    else return '';
  });

  Handlebars.registerHelper('gravatar_hash', function(email) {
    return md5(email.trim().toLowerCase());
  });

  return {};
});
