Rails.application.routes.draw do
  devise_for :users, path: 'sessions', path_names: {
    sign_in: 'new',
    sign_out: 'logout',
    password: 'secret',
    confirmation: 'verification',
    unlock: 'unblock',
    # registration: 'register',
    # sign_up: 'cmon_let_me_in'
  }

  root 'application#landing'

  get '/dashboard', controller: :users, action: :dashboard, as: :user_dashboard
  get '/logout', controller: :sessions, action: :logout, as: :logout

  get '/welcome', controller: :guests, action: :index

  scope '/users', controller: :users do
    get '/:user_id', action: :show, as: :user
    patch '/:user_id', action: :update
    post '/nickname_availability', action: :nickname_availability, as: :nickname_availability
  end

  scope '/settings', controller: :settings do
    get '/', action: :index, as: :settings
  end

  match '*path' => 'application#rogue_route', via: :all
  match '/' => 'application#rogue_route', via: :all
end
