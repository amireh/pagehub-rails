class Api::V2::PagesController < ApiController
  def index
    scope = if params[:space_id]
      Space.find(params[:space_id])
    elsif params[:folder_id]
      Folder.find(params[:folder_id])
    end

    authorize! :read, scope

    render 'api/v2/pages/index', locals: {
      pages: scope.pages
    }
  end

  def create
    folder = Folder.find(params[:folder_id])
    space = folder.space

    authorize! :author, space,
      :message => 'You need to be an editor of this space to create pages.'

    authorize! :author_more, space,
      :message => 'You can not create any more pages in this space.'

    xparams = params.fetch(:page, {}).permit(:title, :content, :browsable)

    page = folder.pages.create(xparams.merge({
      user_id: current_user.id
    }))

    unless page.valid?
      halt! 422, page.errors
    end

    render 'api/v2/pages/index', locals: {
      pages: [ page ]
    }
  end

  def show
    page = Page.find(params[:page_id])

    authorize! :read, page

    render 'api/v2/pages/index', locals: {
      pages: [ page ]
    }
  end

  def update
    page = Page.find(params[:page_id])
    space = page.space

    authorize! :author, space,
      message: "You need to be an editor of this space to edit pages."

    unless Lux::Lock.for(page).acquire!(holder: current_user) == Lux::LOCK_OK
      return head 409
    end

    xparams = params.require(:page).permit(:title, :content, :browsable, :folder_id, :encrypted, :digest)

    if new_folder_id = xparams[:folder_id]
      new_folder = Folder.find(new_folder_id)

      if new_folder.space != space
        halt! 422, "You can only move pages between folders within the same space."
      end
    end

    if new_content = xparams[:content]
      PageHub::Markdown::mutate! xparams[:content]

      begin
        unless page.generate_revision(new_content, current_user)
          halt! 500, page.collect_errors
        end
      rescue PageRevision::NothingChangedError
        # it's ok
      rescue PageRevision::PatchTooBigError
        # it's fine, too
      end
    end

    unless page.update(xparams)
      halt! 422, page.errors
    end

    render 'api/v2/pages/index', locals: {
      pages: [ page ]
    }
  end

  def destroy
    page = Page.find(params[:page_id])

    unless Lux::Lock.for(page).acquire!(holder: current_user) == Lux::LOCK_OK
      return head 409
    end

    authorize! :delete, page,
      message: "You can not remove pages authored by someone else."

    unless page.destroy
      halt! 500, page.errors
    end

    Lux::Lock.for(page).release!(holder: current_user)

    head 204
  end
end
