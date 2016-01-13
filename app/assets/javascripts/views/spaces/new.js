define([ 'backbone', 'jquery', 'pagehub', 'core/Notification', 'utils/ajax',
'utils/serializeForm', 'core/APIError' ],
function(Backbone, $, UI, Notification, ajax, serializeForm, APIError) {
  var NewSpaceView = window.PHLegacy.NewSpaceView = Backbone.View.extend({
    el: $("body"),

    events: {
      'click #check_availability': 'check_availability',
      'keyup input[type=text][name=title]': 'queue_availability_check',
      'submit form': 'save'
    },

    initialize: function(app) {
      this.space = app.space;

      this.check_timer = null;
      this.check_pulse = 250;
      this.elements = {
        title:                this.$el.find('input[type=text][name=title]'),
        availability_checker: this.$el.find('#check_availability'),
        title_availability:   this.$el.find('#check_availability i'),
        brief:                this.$el.find('input[type=text][name=brief]'),
        is_public:            this.$el.find('input[type=checkbox][name=is_public]')
      }

      app.trigger('bootstrapped', app);
    },

    consume: function(e) {
      e.preventDefault();
      return false;
    },

    queue_availability_check: function() {
      if (this.check_timer) {
        clearTimeout(this.check_timer);
        this.check_timer = null;
      }

      var view = this;
      this.check_timer = setTimeout(function() { return view.check_availability(); }, this.check_pulse)

      return false;
    },

    check_availability: function() {
      var btn   = this.elements.availability_checker,
          title  = this.elements.title.val().trim(),
          view  = this;

      // e.preventDefault();

      if (title.length == 0) {
        btn.addClass('btn-danger').removeClass('btn-success').find('i').addClass('icon-remove');
        return false;
      }

      ajax({
        url: `/api/users/${ENV.current_user.id}/spaces/title_availability`,
        type: "POST",
        data: JSON.stringify({ title: title })
      }).then(function(status) {
        if (status.available) {
          btn
            .removeClass('btn-danger')
            .addClass('btn-success')
            .find('i')
              .removeClass('icon-remove')
          ;
        } else {
          btn
            .removeClass('btn-success')
            .addClass('btn-danger')
            .find('i')
              .addClass('icon-remove')
          ;
        }
      });

      return false;
    }, // check_availability

    save: function(e) {
      e.preventDefault();

      var params = serializeForm(this.$('form')[0]);

      ajax({
        url: ENV.links.create_space,
        type: 'POST',
        data: JSON.stringify(params)
      }).then(function(payload) {
        const space = payload.spaces[0];

        Notification.spawn('Great! Will take you now to your new space.', 'notice');
        window.location = space.links.edit;
      }, function(xhrError) {
        var error = new APIError(xhrError);
        var notification = new Notification(error.messages[0], 'error');
      });

      return false;
    }
  });

  return NewSpaceView;
});