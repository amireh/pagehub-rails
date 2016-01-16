class Api::FoldersController < ::ApiController
  before_filter :require_space
  before_filter :require_folder, only: [ :show, :update, :destroy ]

  def index
    authorized_action! :read, @space

    render locals: {
      folders: @space.folders.includes(:user, :folder),
      compact: true
    }
  end

  def show
    authorized_action! :read, @folder

    render 'api/folders/index', locals: { folders: [@folder] }
  end

  def create
    authorize! :author, @space
    attrs = params.fetch(:folder, {}).permit(:title, :folder_id)

    folder = @space.folders.create!(attrs.merge({ user_id: current_user.id }))

    render 'api/folders/index', locals: { folders: [folder] }
  end

  def update
    space = @space
    authorize! :author, space,
      message: "You need to be an editor of this space to edit folders."

    folder = @folder

    authorize! :edit, folder

    new_params = params.require(:folder).permit(:title, :browsable, :folder_id)

    if new_folder_id = new_params[:folder_id]
      new_folder = Folder.find(new_folder_id)

      if new_folder.space != space
        halt! 422, "You can only move folders between folders within the same space."
      end
    end

    unless folder.update(new_params)
      halt! 400, folder.errors
    end

    render 'api/folders/index', locals: { folders: [folder] }
  end

  def destroy
    authorize! :author, @space
    authorize! :delete, @folder

    @folder.destroy!

    head 204
  end

  private

  def require_space
    @space = Space.find(params[:space_id])
  end

  def require_folder
    @folder = @space.folders.find(params[:folder_id])
  end
end