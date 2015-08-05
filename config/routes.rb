Rails.application.routes.draw do
  devise_for :users, path: '/', path_names: {
    sign_in: 'login',
    password: 'password',
    confirmation: '/users/verifications',
  }, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: 'users/registrations'
  }

  devise_scope :user do
    get '/logout', to: 'sessions#logout', as: :logout
  end

  root 'application#landing'

  get '/dashboard', controller: :users, action: :dashboard, as: :user_dashboard
  # get '/logout', controller: :sessions, action: :logout, as: :logout
  get '/new', controller: :spaces, action: :new, as: :new_space
  get '/welcome', controller: :guests, action: :index

  namespace :api do
    namespace :v1 do
      scope '/users', controller: :users do
        post '/nickname_availability', {
          action: :nickname_availability,
          as: :user_nickname_availability
        }

        post '/resend_confirmation_instructions', {
          action: :resend_confirmation_instructions,
          as: :user_resend_confirmation_instructions
        }

        scope '/:user_id' do
          get '/', action: :show, as: :user
          patch '/', action: :update
        end
      end

      scope '/users/:user_id/spaces', controller: :spaces do
        get '/', action: :index, as: :user_spaces
        post '/', action: :create, as: :create_user_space
        get '/:space_id', action: :show, as: :user_space
        patch '/:space_id', action: :update
        patch '/:space_id/memberships', action: :update_memberships, as: :user_space_memberships
      end

      scope '/spaces/:space_id/folders', controller: :folders do
        get '/', action: :index, as: :space_folders
        get '/:folder_id', action: :show, as: :space_folder
      end

      scope '/folders/:current_folder_id/pages', controller: :pages do
        get '/', action: :index, as: :folder_pages
        get '/:page_id', action: :show, as: :folder_page
        post '/', action: :create
        patch '/:page_id', action: :update
        delete '/:page_id', action: :destroy
      end
    end # namespace :v1
  end # namespace :api

  scope '/settings', controller: :settings do
    get '/', action: :index, as: :settings
  end

  scope '/:user_nickname', controller: :users do
    get '/', action: :show, as: :user

    scope '/:space_pretty_title', controller: :spaces do
      get '/', action: :show, as: :user_space
      get '/new', action: :new_resource, as: :new_space_resource
      get '/edit', action: :edit, as: :user_space_edit
      get '/settings', action: :settings, as: :user_space_settings

      scope '/:folder_pretty_title', controller: :folders do
        get '/', action: :show, as: :space_folder

        scope '/:page_pretty_title', controller: :pages do
          get '/', action: :show, as: :folder_page
        end
      end
    end
  end

  match '*path' => 'application#rogue_route', via: :all, as: :generic_resource
  match '/' => 'application#rogue_route', via: :all
end
