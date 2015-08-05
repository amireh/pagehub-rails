define([ 'jquery' ], function($) {
  var Notification = function(message, type) {
    var $el = $('<div />', {
      class: [ 'flash', 'flash--' + type ].join(' '),
    });

    $el.text(message);
    $el.appendTo($('#flash-messages'));

    return {
      remove: function() {
        $el.remove();
      }
    }
  };

  Notification.spawn = function(message, type) {
    return new Notification(message, type);
  };

  return Notification;
})