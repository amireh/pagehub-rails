class SettingsController < ApplicationController
  respond_to :html

  before_filter :require_user, except: []

  def index
    @spaces = current_user.spaces.includes(:space_users, :user, :pages)

    respond_to do |format|
      format.html
    end
  end
end
