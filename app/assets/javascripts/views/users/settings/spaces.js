define([
  'views/shared/settings/setting_view',
  'jquery',
  'pagehub',
  'hbs!templates/users/settings/dialog_leave_space_warning'
],

function(SettingView, $, UI, LeaveSpaceWarningDlgTmpl) {
  return SettingView.extend({
    el: $("#user_spaces_settings"),

    templates: {
      leave_space_warning: LeaveSpaceWarningDlgTmpl
    },

    events: {
      'click button[data-role=leave_space]': 'confirm_space_leaving'
    },

    initialize: function(data) {
      SettingView.prototype.initialize.apply(this, arguments);

      this.elements = {
      }

      this.unserializable = true;
    },

    confirm_space_leaving: function(e) {
      var el = $(e.target),
          view = this,
          space_id = el.parents('[data-space]:first').attr('data-space');

      $(this.templates.leave_space_warning()).dialog({
        dialogClass: "alert-dialog",
        buttons: {
          Cancel: function() {
            $(this).dialog("close");
          },

          Confirm: function() {
            $(this).dialog("close");

            view.leaveSpace(space_id);
          }
        }
      })
    },

    leaveSpace: function(spaceId) {
      var space = this.model.spaces.get(spaceId);
      var $list = this.$el;

      if (!space) {
        console.warn('Space with id %s could not be found!!!', spaceId);
        return;
      }

      space.modify_membership(this.user.get('id'), null).then(function() {
        UI.status.show("You are no longer a member of " + space.get('title') + ".", "good");
        $list.find('[data-space=' + space.get('id') + ']').remove();
      });
    },

    serialize: function() {
      return {};
    }
  });
});