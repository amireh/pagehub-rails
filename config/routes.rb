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

  root 'guest#index'

  scope '/users', controller: :users do
    get '/:user_id', action: :show, as: :user
  end

  scope '/settings', controller: :settings do
    get '/', action: :index, as: :settings
  end
end
