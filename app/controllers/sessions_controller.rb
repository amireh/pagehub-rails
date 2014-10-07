class SessionsController < ApplicationController
  before_filter :require_user, only: [ :logout ]

  def logout
    user = current_user
    sign_out current_user
    redirect_to after_sign_out_path_for(user)
  end
end
