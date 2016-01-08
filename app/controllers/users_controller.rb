class UsersController < ApplicationController
  respond_to :html

  before_filter :require_user, only: [ :dashboard ]

  def dashboard
    spaces = current_user.spaces.includes(:user, :folders, :pages, :space_users)

    respond_to do |format|
      format.html do
        @can_create_spaces = true
        @user = current_user

        js_env({
          spaces: json_render_set(spaces, SpaceSerializer)
        })
      end
    end
  end

  def show
    unless user = User.where(nickname: params[:user_nickname]).first
      halt! 404
    end

    if user == current_user
      return redirect_to action: :dashboard
    end

    spaces = user.spaces.where(is_public: true)

    respond_to do |format|
      format.html do
        @user = user

        js_env({
          user: ams_render_object(user, UserSerializer),
          spaces: json_render_set(spaces, SpaceSerializer)
        })

        render :"dashboard"
      end
    end
  end
end
