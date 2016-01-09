const React = require('react');
const { func, bool, string } = React.PropTypes;

const Login = React.createClass({
  propTypes: {
    loading: bool,
    onLogin: func.isRequired,
    loginError: string,
  },

  render() {
    return (
      <div>
        <h2 className="blocky-heading">Sign in</h2>

        {this.props.loginError && (
          <pre className="alert alert-danger">
            {this.props.loginError}
          </pre>
        )}

        <form method="POST" action="/login" className="login-form" onSubmit={this.login}>
          <fieldset className="form-horizontal">
            <div className="control-group">

              <label htmlFor="email" className="control-label">
                Email
              </label>

              <div className="controls">
                <input ref="email" type="email" name="email" autoFocus />
              </div>
            </div>

            <div>
              <label htmlFor="password" className="control-label">Password</label>
              <div className="controls">
                <input
                  ref="password"
                  type="password"
                  name="password"
                  autoComplete={false}
                />
              </div>
            </div>

            <div className="controls">
              <div>
                <p>
                  <label>
                    <input ref="rememberMe" type="checkbox" name="remember_me" />
                    {' '}
                    Remember Me
                  </label>
                </p>

                <button
                  type="submit"
                  className="btn"
                  disabled={this.props.loading}
                >
                  Sign in
                </button>
              </div>
            </div>
          </fieldset>
        </form>
      </div>
    );
  },

  login(e) {
    e.preventDefault();

    this.props.onLogin({
      email: this.refs.email.value,
      password: this.refs.password.value,
      rememberMe: this.refs.rememberMe.checked
    });
  }
});

module.exports = Login;
