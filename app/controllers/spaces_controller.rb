class SpacesController < ApplicationController
  respond_to :html

  before_filter :require_user

  def edit
    @space = current_user.spaces.
      where(pretty_title: params[:space_pretty_title]).
      includes(:user).first

    halt! 404 if @space.nil?

    js_env({
      space: Rabl.render(@space, 'spaces/show', {
        format: :hash,
        scope: self,
        include_json_root: false,
        include_child_root: false
      })
    })

    respond_with @space
  end
end
