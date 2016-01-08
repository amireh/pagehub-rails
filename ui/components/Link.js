const React = require('react');
const RouteMap = {
  'features': '/features',
  'users.new': '/sign_up',
  'auth.github': '/auth/github',
};

const Link = React.createClass({
  render() {
    return (
      <a {...this.props} href={RouteMap[this.props.to] || this.props.href} />
    );
  }
});

module.exports = Link;
