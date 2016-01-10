class Api::SessionsController < ApiController
  def create
    sign_in current_user

    render '/api/users/index', locals: { users: [ current_user ] }
  end
end
