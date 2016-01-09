const { assert } = require('chai');
const sinon = require('./shims/sinon');
const ReactDOM = require('react-dom');

sinon.assert.expose(assert, { prefix: "" });

exports.assert = assert;
exports.sinonSuite = function(suite) {
  let sandbox;

  suite.beforeEach(function() {
    sandbox = sinon.sandbox.create({
      useFakeServer: true,
      useFakeTimers: true
    });
  });

  suite.afterEach(function() {
    sandbox.restore();
  });

  return () => sandbox;
};


exports.createDOMOutlet = function(suite, options = { attachToDOM: false }) {
  let node;
  const API = {};
  Object.defineProperty(API, 'node', { get: () => node });

  beforeEach(function() {
    node = document.createElement('div');

    if (options.attachToDOM) {
      document.body.appendChild(node);
    }
  });

  afterEach(function() {
    ReactDOM.unmountComponentAtNode(node);

    node.remove();
  });

  return API;
};

exports.renderIntoOutlet = function(component, node) {
  return ReactDOM.render(component, node);
};