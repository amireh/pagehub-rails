class Api::V1::FoldersController < ::ApiController
  before_filter :require_space
  before_filter :require_folder, only: [ :show ]

  def index
    authorized_action! :read, @space

    params[:compact] = true
    ams_expose_object @space.folders.includes(:user, :folder)
  end

  def show
    authorized_action! :read, @folder

    ams_expose_object @folder
  end

  private

  def require_space
    @space = Space.find(params[:space_id])
  end

  def require_folder
    @folder = @space.folders.find(params[:folder_id])
  end
end