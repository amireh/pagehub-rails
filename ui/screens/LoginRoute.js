const React = require('react');
const { assign, compose, partial } = require('lodash');
const Login = require('./Login');
const ajax = require('../utils/ajax');

module.exports = {
  path: '/login',
  handler(renderComponent) {
    const setStateAndRender = compose(render, setState);
    const state = getInitialState();

    render();

    function getInitialState() {
      return {
        loading: false,
        loginError: null
      };
    }

    function render() {
      renderComponent(
        <Login
          {...state}
          onLogin={compose(
            IO(compose(reload, displayLoadingStatus(false)), displayError),
            login,
            Pipe(displayLoadingStatus(true))
          )}
        />
      );
    }

    function displayLoadingStatus(flag) {
      return partial(setStateAndRender, { loading: flag });
    }

    function login(creds) {
      return ajax({
        url: '/api/sessions',
        type: 'POST',
        headers: {
          'Authorization': `Basic ${btoa(creds.email + ':' + creds.password)}`
        }
      });
    }

    function displayError(jqXHR) {
      setStateAndRender({
        loading: false,
        loginError: extractJqXHRError(jqXHR)
      });
    }

    function setState(newState) {
      assign(state, newState);
    }

    function reload() {
      window.location.reload();
    }
  }
};

function IO(f, g) {
  return function(x) {
    return x.then(f, g);
  };
};

function Pipe(f) {
  return function(x) {
    f(x);

    return x;
  };
}

function extractJqXHRError(jqXHR) {
  if (jqXHR.responseJSON) {
    if (jqXHR.responseJSON.errors /* devise_token */) {
      return jqXHR.responseJSON.errors[0];
    }
    else if (jqXHR.responseJSON.status === 'error' /* pagehub */) {
      return jqXHR.responseJSON.messages[0];
    }
  }
  else {
    return jqXHR.responseText; // sadness
  }
}