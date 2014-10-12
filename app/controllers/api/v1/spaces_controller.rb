class Api::V1::SpacesController < ::ApiController
  before_filter :require_user

  def index
    authorized_action! :read, @user
    params[:compact] = true
    ams_expose_object @user.spaces.includes(:user)
  end

  def show
    space = Space.find(params[:space_id])

    authorized_action! :read, space

    # eager load the assocs .. especially the space_users as that kills!
    space = Space.
      where(id: params[:space_id]).
      includes(:user, :space_users, :pages, :folders).
      first

    ams_expose_object space
  end

  private

end
