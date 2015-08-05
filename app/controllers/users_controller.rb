class UsersController < ApplicationController
  respond_to :html

  before_filter :require_user

  def dashboard
    @user = current_user
    spaces = current_user.spaces.includes(:user, :folders, :pages, :space_users)
    js_env(spaces: json_render_set(spaces, SpaceSerializer))
  end

  def show
    redirect_to action: :dashboard
  end
end
