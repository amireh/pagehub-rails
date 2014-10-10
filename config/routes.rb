Rails.application.routes.draw do
  devise_for :users, path: '/', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    password: 'password',
    confirmation: 'verification',
    unlock: 'unblock',
    # registration: 'register',
    # sign_up: 'cmon_let_me_in'
  }, controllers: {
    :omniauth_callbacks => "users/omniauth_callbacks"
  }

  root 'application#landing'

  get '/dashboard', controller: :users, action: :dashboard, as: :user_dashboard
  get '/logout', controller: :sessions, action: :logout, as: :logout

  get '/welcome', controller: :guests, action: :index

  scope '/users', controller: :users do
    post '/nickname_availability', action: :nickname_availability, as: :nickname_availability
    post '/resend_confirmation_instructions', {
      action: :resend_confirmation_instructions,
      as: :resend_confirmation_instructions
    }

    scope '/:nickname' do
      get '/', action: :show, as: :user
      patch '/', action: :update

      scope '/:space', controller: :spaces do
        get '/', action: :show, as: :user_space
        get '/edit', action: :edit, as: :user_space_editor
        get '/settings', action: :settings, as: :user_space_settings
      end
    end
  end

  scope '/settings', controller: :settings do
    get '/', action: :index, as: :settings
  end

  match '*path' => 'application#rogue_route', via: :all
  match '/' => 'application#rogue_route', via: :all
end
