class SettingsController < ApplicationController
  before_filter :require_user, except: []

  def index
  end
end
