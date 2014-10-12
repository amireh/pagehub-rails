class SpacesController < ApplicationController
  respond_to :html

  before_filter :require_user

  def edit
    @space = current_user.spaces.
      where(pretty_title: params[:space_pretty_title]).
      includes(:user, :folders, :pages).first

    halt! 404 if @space.nil?

    js_env({
      space: ams_render_object(@space, SpaceSerializer, {
        include: [ :pages ]
      }),
      space_creator: {
        id: @space.user.id.to_s
      }
    })

    respond_with @space
  end

  def show
    respond_with @space
  end
end
