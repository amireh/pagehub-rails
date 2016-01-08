const React = require('react');
const Link = require('../components/Link');

const Welcome = React.createClass({
  render() {
    return (
      <div id="landing_page" className="landing-page">
        <div className="greeting hero-unit">
          <h1>Write!</h1>

          <p>
            Welcome to PageHub, an open editing platform that's all about
            <strong>authoring</strong> and <strong>publishing</strong> content.
          </p>

          <p className="type-small">
            Whether you're a software developer documenting your software,
            a student taking notes, or just looking for a place to
            <em>write</em>, PageHub's <Link to="features">loaded features</Link>,
            and easy-to-use interface will hit the spot right on for you.
          </p>

          <hr />

          <div className="actions">
            <Link to="users.new" className="btn btn-large btn-success">
              Sign up
            </Link>
            {' '}
            <Link
              to="auth.github"
              className="btn"
              rel="tooltip"
              title="Sign in using your GitHub account"><i className="icon github icon16"></i>
            </Link>
          </div>
        </div>

        <div className="row-fluid text-center">

          <div className="span4">
            <img src="/assets/icons/landing_page/screen.png" />

            <h4>Write it and we'll format it</h4>
            <p>
              Documents you author on PageHub can be accessed as
              {' '}
              <Link href="/features#spaces-browsing">web pages in a browser</Link>,

              and can also be exported to a number of formats like TXT, PDF, or Word.
            </p>
          </div>

          <div className="span4">
            <img src="/assets/icons/landing_page/tree.png" />

            <h4>Organize via an intuitive interface</h4>
            <p>
              Use the file browser to organize your pages (and folders) like you would
              with conventional file browsers.
            </p>
          </div>

          <div className="span4">
            <img src="/assets/icons/landing_page/multi-agents.png" />
            <h4>Collaborate with others</h4>
            <p>
              Start a space with friends or colleagues
              to write and edit together, and share your work.
            </p>
          </div>
        </div>
      </div>
    );
  }
});

module.exports = Welcome;
