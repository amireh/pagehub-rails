class Api::V1::SessionsController < ApiController
  def create
    sign_in current_user

    render template: '/api/users/index', locals: { users: [ current_user ] }
  end
end
