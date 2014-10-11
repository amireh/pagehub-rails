Rails.application.routes.draw do
  devise_for :users, path: '/', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    password: 'password',
    confirmation: 'verification',
  }, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: 'users/registrations'
  }

  root 'application#landing'

  get '/dashboard', controller: :users, action: :dashboard, as: :user_dashboard
  get '/logout', controller: :sessions, action: :logout, as: :logout

  get '/welcome', controller: :guests, action: :index

  scope '/api/v1' do
    scope '/users', controller: :users_api do
      post '/nickname_availability', {
        action: :nickname_availability,
        as: :api_user_nickname_availability
      }

      post '/resend_confirmation_instructions', {
        action: :resend_confirmation_instructions,
        as: :api_user_resend_confirmation_instructions
      }

      scope '/:id' do
        get '/', action: :show, as: :api_user
        patch '/', action: :update

        scope '/spaces', controller: :api_spaces do
          get '/', action: :index, as: :api_user_spaces
          get '/:id', action: :show, as: :api_user_space
        end
      end
    end

    scope '/spaces', controller: :api_spaces do
      scope '/:space_id' do
        scope '/folders', controller: :api_folders do
          get '/', action: :show, as: :api_space_folder
        end

        scope '/pages', controller: :api_pages do
          get '/', action: :show, as: :api_space_page
        end
      end
    end
  end

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

  match '*path' => 'application#rogue_route', via: :all
  match '/' => 'application#rogue_route', via: :all
end
