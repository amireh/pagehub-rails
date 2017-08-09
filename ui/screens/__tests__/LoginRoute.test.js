const Subject = require("../LoginRoute");
const { assert, sinonSuite, createDOMOutlet, renderIntoOutlet } = require('../../TestUtils');
const { drill, m } = require('react-drill');

describe("LoginRoute", function() {
  const sandbox = sinonSuite(this);
  const outlet = createDOMOutlet(this);

  it('renders', function() {
    let onRender = sandbox().stub();

    Subject.handler(onRender);

    assert.calledOnce(onRender);
  });

  it('dispatches a login request', (done) => {
    render((component) => {
      drill(component).find('form').submit();

      assert.equal(sandbox().server.requests.length, 1);

      done();
    });
  });

  it('disables the form while authenticating', (done) => {
    render((component) => {
      drill(component).find('form').submit();

      assert.ok(
        drill(component)
          .find('button', m.hasText('Sign in'))
            .node.disabled
      );

      done();
    });
  });

  it('displays an authentication error', (done) => {
    render((component) => {
      drill(component).find('form').submit();

      sandbox().server.requests[0].respond(401, { 'Content-Type': 'application/json' }, JSON.stringify({
        errors: ['Bad credentials']
      }));

      assert.match(drill(component).node.textContent, 'Bad credentials');

      done();
    });
  });

  function render(f) {
    const yieldInitialInstance = Once(f);

    Subject.handler((component) => {
      yieldInitialInstance(renderIntoOutlet(component, outlet.node));
    });
  }
});

function Once(f) {
  let called = false;
  let result;

  return function memoized(x) {
    if (!called) {
      called = true;
      result = f(x);
    }

    return result;
  }
}