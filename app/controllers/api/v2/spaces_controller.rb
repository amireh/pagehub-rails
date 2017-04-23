class Api::V2::SpacesController < ::ApiController
  before_filter :require_user
  before_filter :require_space, only: [ :show, :update, :destroy ]

  def index
    authorize! :read, current_user

    render locals: {
      spaces: current_user.spaces
    }
  end

  def create
    authorize! :create, Space

    svc = SpaceService.new

    space_params = params.require(:space).permit(:title, :brief, :is_public)

    halt! 422, "Missing required parameter 'title'" if space_params[:title].blank?

    result = svc.create(current_user, space_params)

    halt! 400, result.error unless result.successful?

    space = result.output

    render 'api/v2/spaces/show', locals: {
      spaces: [space],
    }
  end

  def show
    authorize! :read, @space

    render 'api/v2/spaces/show', locals: { spaces: [@space] }
  end

  def update
    authorize! :update, @space

    space_params = params.require(:space).permit(:title, :brief, :is_public, {
      preferences: space_preferences_params
    })

    if space_params[:title]
      authorize! :update_meta, @space
    end

    SpaceService.new.update(@space, space_params)

    render 'api/v2/spaces/show', locals: { spaces: [@space] }
  end

  def destroy
    authorize! :delete, @space

    @space.destroy!

    head 204
  end

  private

  def require_space
    @space = current_user.spaces.find(params[:space_id])
  end

  def space_preferences_params
    {
      publishing: [
        :custom_css,
        { navigation_links: [ :uri, :title ] },
        { layout: [ :name, :show_breadcrumbs, :show_homepages_in_sidebar ] },
        { theme: [ :name ] },
      ],
    }
  end
end
