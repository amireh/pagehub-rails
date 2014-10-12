class SessionsController < Devise::SessionsController
  before_filter :require_user, only: [ :logout ]

  def logout
    sign_out current_user
    redirect_to after_sign_out_path_for(current_user)
  end
end
