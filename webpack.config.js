var path = require('path');
var webpack = require('webpack');
var root = path.resolve(__dirname);
var legacyRoot = path.join(root, 'app/assets/javascripts');

module.exports = {
  devtool: process.env.NODE_ENV === 'production' ? null : 'eval',

  plugins: [

    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.CommonsChunkPlugin('vendor', 'pagehub__vendor.js'),
  ],

  entry: {
    main: [
      './ui/index.js',
    ],

    legacy: './ui/legacy/index.js',
    vendor: []
  },

  output: {
    path: path.join(root, 'public/javascripts'),
    filename: 'pagehub__[name].js',
  },

  // externals: {
  //   'jquery': 'jQuery',
  //   'underscore': '_'
  // },

  resolveLoader: {
    alias: {
      'hbs': path.resolve(root, 'webpack/identity-loader.js'),
    }
  },

  resolve: {
    root: [
      path.join(root),
      path.join(legacyRoot),
    ],

    extensions: [ '', '.js', '.hbs' ],

    alias: {
      'jquery':                 legacyFile('vendor/jquery-1.11.1'),
      'jquery.ui':              legacyFile('vendor/jquery-ui/jquery-ui-1.10.1.custom.min'),
      'jquery.tinysort':        legacyFile('vendor/jquery.tinysort.min'),
      'underscore':             'lodash',
      // 'underscore':             legacyFile('vendor/underscore-min'),
      // 'underscore.inflection':  legacyFile('vendor/underscore/underscore.inflection'),
      'backbone':               legacyFile('shims/backbone'),
      'backbone.nested':        legacyFile('vendor/backbone/deep-model.min'),
      // 'Handlebars':             path.join(root, 'node_modules/handlebars/runtime.js'),
      // 'hbs':                    legacyFile('vendor/hbs/hbs'),
      // 'hbs/i18nprecompile':     legacyFile('vendor/hbs/i18nprecompile'),
      'shortcut':               legacyFile('shims/shortcut'),
      'bootstrap':              legacyFile('shims/bootstrap'),
      'pagehub':                legacyFile('lib/pagehub'),
      'timed_operation':        legacyFile("lib/timed_operation"),
      'pagehub.state':          legacyFile('state'),
      'inflection':             legacyFile('vendor/inflection'),
      'md5':                    legacyFile("vendor/md5"),
      'animable_view':          legacyFile('views/shared/animable_view'),
      'canvas-loader':          legacyFile('vendor/heartcode-canvasloader-min'),
      // 'cm':                     legacyFile('vendor/codemirror-4.5'),
    }
  },

  module: {
    noParse: /vendor|(node_modules\/sinon)/,
    loaders: [{
      test: /\.js$/,
      loaders: [ 'babel?presets[]=es2015&presets[]=react' ],
      include: [
        path.join(root, 'ui')
      ]
    }, {
      test: /\.md$/,
      loaders: [ 'text', path.join(root, 'webpack/markdown-loader') ],
      include: [
        path.join(root, 'ui')
      ]
    }, {
      test: /\.hbs$/,
      loaders: [ 'handlebars-loader' ],
      include: [
        path.join(legacyRoot, 'templates')
      ]
    }, {
      test: /handlebars\.js/,
      loader: 'exports?Handlebars!imports?this=>window',
      include: [
        path.join(legacyRoot, 'vendor')
      ]
    }]
  }
};

function legacyFile(filePath) {
  return path.join(legacyRoot, filePath);
}