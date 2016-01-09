// This profile loads up the entire app and supports coverage instrumentation.

var tests;

if (process.env.COVERAGE === '1') {
  // require("../coverage_setup");
}

// crap exported by require.js
window.jQuery = require('../app/assets/javascripts/vendor/jquery-1.11.1.js');
window._ = require('lodash');

// Run all the tests.
tests = require.context("./", true, /__tests__\/.*\.test\.js$/);
tests.keys().forEach(tests);
