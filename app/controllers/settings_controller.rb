class SettingsController < ApplicationController
  before_filter :require_user, except: []

  def index
    @spaces = current_user.spaces.includes(:space_users, :user, :pages)
  end
end
