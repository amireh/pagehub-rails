class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def landing
    if current_user.present?
      redirect_to controller: :users, action: :dashboard
    else
      redirect_to controller: :guest, action: :index
    end
  end
end
