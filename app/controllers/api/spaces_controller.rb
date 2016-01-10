class Api::SpacesController < ::ApiController
  before_filter :require_user
  before_filter :require_space, only: [ :show, :update ]

  def index
    authorize! :read, @user
    render locals: { spaces: @user.spaces.includes(:user), compact: true }
  end

  def create
    authorize! :create, Space

    svc = SpaceService.new

    xparams = params.require(:space).permit(:title, :brief, :is_public)

    halt! 422, "Missing required parameter 'title'" if xparams[:title].blank?

    result = svc.create(current_user, xparams)

    halt! 400, result.error unless result.successful?

    space = result.output
    render 'api/spaces/index', locals: { spaces: [space] }
  end

  def show
    authorize! :read, @space

    space = Space.
      where(id: params[:space_id]).
      includes(:user, :space_users, :pages, :folders).
      first

    render 'api/spaces/index', locals: { spaces: [space] }
  end

  def update
    authorize! :update, @space,
      message: "You need to be an admin of this space to update it."

    space_params = params.require(:space).permit(:title, :brief, :is_public, {
      preferences: space_preferences_params
    })

    if space_params[:title]
      authorize! :update_meta, @space, message: "Only the space creator can do that."
    end

    SpaceService.new.update(@space, space_params)

    render 'api/spaces/index', locals: { spaces: [space] }
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
