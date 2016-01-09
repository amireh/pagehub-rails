var webpackConfig = require('./webpack.config.js');

var config = {
  port: 9876,
  frameworks: [ 'mocha' ],
  browsers: [ 'chrome_without_security' ],

  plugins: [
    'karma-mocha',
    'karma-chrome-launcher',
    'karma-webpack',
    'karma-sourcemap-loader',
  ],

  customLaunchers: {
    chrome_without_security: {
      base: 'Chrome',
      flags: [
        '--no-default-browser-check',
        '--no-first-run',
        '--disable-default-apps',
        '--disable-popup-blocking',
        '--disable-translate',
        '--disable-web-security',
      ]
    }
  },

  // We're tuning this higher up to guard against these disconnects we've been
  // seeing when the build nodes seem to be under heavy load and the browser
  // doesn't reply to Karma in time.
  browserNoActivityTimeout: 480000,
  captureTimeout: 480000,

  proxies: {
  },

  files: [
    {
      pattern: 'public/stylesheets/compiled/**/*.css',
      watched: false,
      included: false,
      served: true
    }
  ],

  reporters: [ 'dots' ],

  client: {
    captureConsole: true,

    mocha: {
      reporter: 'html', // change Karma's debug.html to the mocha web reporter
      ui: 'bdd',
      timeout: 2000
    }
  }
};

config.files.push('ui/TestRunner.js');


config.preprocessors = {
  'ui/TestRunner.js': [ 'webpack', 'sourcemap' ]
};

config.webpack = webpackConfig;
config.webpackMiddleware = {
  noInfo: !process.env.VERBOSE
};

if (process.env.VERBOSE) {
  config.logLevel = 'DEBUG';
}

if (process.env.FIREWORK_URL || process.env.FIREWORK_REPORTER_DB) {
  config.plugins.push('karma-firework-reporter');
  config.reporters.push('firework');
  config.fireworkReporter = {
    fireworkUrl: process.env.FIREWORK_URL,
    fireworkDatabase: process.env.FIREWORK_REPORTER_DB,
    framework: 'mocha'
  };
}

if (process.env.COVERAGE === '1') {
  config.plugins.push('karma-coverage');

  config.reporters.push('coverage');

  config.coverageReporter = {
    dir: 'coverage-js',
    subdir: '.',
    reporters: [
      { type: 'json', file: 'report.json' },
      { type: 'html' },
      { type: 'text-summary' }
    ],
  };
}

module.exports = function(mortalkombat) {
  mortalkombat.set(config);
};
