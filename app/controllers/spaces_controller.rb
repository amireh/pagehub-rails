class SpacesController < ApplicationController
  respond_to :html

  before_filter :require_user, except: [ :show, :pretty_resource ]

  def new
    authorize! :create, Space, message: "You can not create new spaces as a demo user."

    @user  = current_user
    @space = current_user.owned_spaces.new

    js_env({
      user: ams_render_object(@user, UserSerializer),
      links: {
        create_space: api_v1_create_user_space_url(current_user)
      }
    })

    respond_with @space do |format|
      format.html
    end
  end

  def edit
    @space = current_user.spaces.
      where(pretty_title: params[:space_pretty_title]).
      includes(:user, :folders, :pages).first

    halt! 404 if @space.nil?

    authorize! :edit, @space

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

  def settings
    @user = require_slugged_user
    @space = require_slugged_space(@user)

    authorize! :update, @space, message: "You must be an admin of this space to manage it."

    js_env({
      space: ams_render_object(@space, SpaceSerializer, {
        include: [ :pages, :space_users, :folders ]
      }),
      space_creator: {
        id: @space.user.id.to_s
      }
    })
  end

  def show
    user = User.find_by(nickname: params[:user_nickname])

    halt! 404 if user.nil?

    space = user.spaces.
      where(pretty_title: params[:space_pretty_title]).
      includes(:user, :folders, :pages).first

    halt! 404 if space.nil?

    render_pretty_resource(space.homepage)
  end

  def pretty_resource
    user = require_slugged_user
    space = user.spaces
      .includes(:user, :folders, :pages)
      .find_by(pretty_title: params[:space_pretty_title])

    halt! 404, "No such space." if space.nil?

    unless can? :browse, space
      halt! 401, "You are not allowed to browse that space."
    end

    fragments = params[:resource_pretty_title].split('/')

    page = if fragments.empty?
      space.homepage
    else
      space.locate_resource(fragments.map { |f| Addressable::URI.unescape(f) })
    end

    halt! 404, "No resource found at #{fragments}" if page.nil?

    render_pretty_resource(page)
  end

  private

  def render_pretty_resource(page)
    @page = page
    @folder = page.folder
    @space = page.space

    @page_content = if params[:revision_id]
      revision = page.revisions.find(params[:revision_id])
      page.snapshot(revision)
    else
      @page_content = page.content
    end

    respond_to do |format|
      format.html do
        render :"spaces/pretty_resource", layout: "layouts/print"
      end
    end
  end

  def require_slugged_user
    User.find_by(nickname: params[:user_nickname]).tap do |user|
      halt! 404, "User not found." if user.nil?
    end
  end

  def require_slugged_space(user)
    user.spaces.find_by(pretty_title: params[:space_pretty_title]).tap do |space|
      halt! 404 if space.nil?

      authorize! :read, space
    end
  end
end
