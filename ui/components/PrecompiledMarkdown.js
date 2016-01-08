const React = require('react');
const PrecompiledMarkdown = React.createClass({
  render() {
    return (
      <div dangerouslySetInnerHTML={{__html: this.props.children }} />
    );
  }
});

module.exports = PrecompiledMarkdown;
