var path = require('path');
var root = path.resolve(__dirname);

module.exports = {
  entry: {
    main: [
      './ui/index.js',
      './ui/screens/NotFound.js'
    ],
    vendor: []
  },

  output: {
    path: path.join(root, 'public/javascripts'),
    filename: 'pagehub__[name].js',
  },

  module: {
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
    }]
  }
};