class Api::SessionsController < ApiController
  protect_from_forgery with: :exception, except: [ :generate_csrf_token ]

  def create
    sign_in current_user

    render '/api/users/index', locals: { users: [ current_user ] }
  end

  def generate_csrf_token
    render json: { csrf_token: form_authenticity_token }.to_json
  end
end
