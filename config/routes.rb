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
  get '/new', controller: :spaces, action: :new, as: :new_space
  get '/welcome', controller: :guests, action: :index
  get '/features', controller: :guests, action: :features
  get '/open-source', controller: :guests, action: :open_source

  namespace :api, format: :json do
    namespace :v2 do
      scope '/spaces', controller: :spaces do
        get '/', action: :index
        post '/', action: :create
        get '/:space_id', action: :show
        patch '/:space_id', action: :update
        delete '/:space_id', action: :destroy
      end

      resources :pages, only: [ :create, :index ] do
        get '/', action: :show
        patch '/', action: :update
        delete '/', action: :destroy
      end

      resources :locks, only: [] do
        collection do
          post '/', action: :create
          patch '/', action: :update
          delete '/', action: :destroy
        end
      end
    end

    resources :sessions do
      post :create
      post '/csrf_tokens', action: :generate_csrf_token
    end

    scope '/users', controller: :users do
      post '/nickname_availability', {
        action: :nickname_availability,
        as: :user_nickname_availability
      }

      post '/resend_confirmation_instructions', {
        action: :resend_confirmation_instructions,
        as: :user_resend_confirmation_instructions
      }

      get '/search', action: :search

      scope '/:user_id' do
        get '/', action: :show, as: :user
        patch '/', action: :update
      end
    end

    scope '/users/:user_id/spaces', controller: :spaces do
      get '/', action: :index, as: :user_spaces
      post '/', action: :create, as: :create_user_space
      post '/title_availability', action: :title_availability
      get '/:space_id', action: :show, as: :user_space
      patch '/:space_id', action: :update
      patch '/:space_id/memberships', action: :update_memberships, as: :user_space_memberships
      delete '/:space_id', action: :destroy
    end

    scope '/spaces/:space_id/memberships', controller: :space_memberships do
      get '/', action: :index
      post '/:user_id', action: :create
      patch '/:user_id', action: :update
      delete '/:user_id', action: :destroy
    end

    scope '/spaces/:space_id/folders', controller: :folders do
      get '/', action: :index, as: :space_folders
      get '/:folder_id', action: :show, as: :space_folder
      post '/', action: :create
      patch '/:folder_id', action: :update
      delete '/:folder_id', action: :destroy
    end

    scope '/folders/:folder_id/pages', controller: :pages do
      get '/', action: :index, as: :folder_pages
      get '/:page_id', action: :show, as: :folder_page
      post '/', action: :create
      patch '/:page_id', action: :update
      delete '/:page_id', action: :destroy
    end
  end # namespace :api

  scope '/settings', controller: :settings do
    get '/', action: :index, as: :settings
  end

  resources :pages, only: [ :edit ] do
    resources :revisions, controller: :page_revisions, param: :revision_id, only: [] do
      collection do
        get '/', action: :index
      end

      member do
        get '/', action: :show
        post '/', action: :rollback, as: :rollback
      end
    end
  end

  scope '/:user_nickname', controller: :users do
    get '/', action: :show, as: :user

    scope '/:space_pretty_title', controller: :spaces do
      get '/', action: :show, as: :user_space
      get '/new', action: :new_resource, as: :new_space_resource
      get '/edit', action: :edit, as: :user_space_edit
      get '/settings', action: :settings, as: :user_space_settings

      get '*resource_pretty_title', action: :pretty_resource, as: :user_pretty_resource
    end
  end

  match '*path' => 'application#rogue_route', via: :all, as: :generic_resource
  match '/' => 'application#rogue_route', via: :all
end
