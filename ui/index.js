const page = require('page');
const React = require('react');
const ReactDOM = require('react-dom');
const Welcome = require('./screens/Welcome');
const NotFound = require('./screens/NotFound');
const Features = require('./screens/Features');

page('/', function() {
  render(<Welcome />);
});

page('/welcome', function() {
  render(<Welcome />);
});

page('/features', function() {
  render(<Features />);
});

// Can't do until the old crap is out.
//
// page('*', function() {
//   render(<NotFound />);
// });

page.start();

function render(component) {
  ReactDOM.render(component, document.querySelector('#content'));
}

console.log('hazzaa!')