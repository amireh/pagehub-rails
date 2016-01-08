const React = require('react');
const PrecompiledMarkdown = require('../components/PrecompiledMarkdown');

const Features = React.createClass({
  render() {
    return (
      <div className="features">
        <PrecompiledMarkdown>
          {require('./Features.md')}
        </PrecompiledMarkdown>
      </div>
    );
  }
});

module.exports = Features;
