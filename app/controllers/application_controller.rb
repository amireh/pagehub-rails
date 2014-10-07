class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :expose_preferences

  def landing
    if current_user.present?
      redirect_to controller: :users, action: :dashboard
    else
      redirect_to controller: :guests, action: :index
    end
  end

  protected

  def require_user
    authenticate_user!
  end

  def js_env(hash)
    @js_env ||= {}
    @js_env.merge!(hash)
  end

  def expose_preferences
    js_env({
      app_preferences: PageHub::Config.defaults
    })
  end
end
