const React = require('react');
const ReactDOM = require('react-dom');
const Shortcut = require('shortcut');

const Dialog = React.createClass({
  getInitialState: function() {
    return {
      computedStyle: {
        marginTop: 0,
        marginLeft: 0
      }
    };
  },

  componentDidMount() {
    Shortcut.add('escape', this.emitClose);
    this.computeStyle();
  },

  componentWillUnmount() {
    Shortcut.remove('escape', this.emitClose);
  },

  componentDidUpdate() {
    this.computeStyle();
  },

  render() {
    return (
      <div className="dialog" style={this.state.computedStyle}>
        <div className="dialog__background" />
        <div className="dialog__content">
          <button className="dialog__close-btn btn--a11y" onClick={this.emitClose}>x</button>

          {this.props.children}
        </div>
      </div>
    );
  },

  computeStyle() {
    const node = ReactDOM.findDOMNode(this);
    const offsets = { w: node.offsetWidth, h: node.offsetHeight };
    const newState = {
      marginTop: -1 * offsets.h / 2,
      marginLeft: -1 * offsets.w / 2,
    };

    if (JSON.stringify(this.state.computedStyle) !== JSON.stringify(newState)) {
      this.setState({ computedStyle: newState });
    }
  },

  emitClose() {
    if (this.props.onClose) {
      this.props.onClose();
    }
  }
});

module.exports = Dialog;
