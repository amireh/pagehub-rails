class Api::PagesController < ApiController
  def index
    folder = Folder.find(params[:folder_id])

    authorize! :read, folder

    render 'api/pages/index', locals: {
      pages: folder.pages.includes(:user)
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

    render 'api/pages/index', locals: {
      pages: [ page ]
    }
  end

  def show
    page = Page.find(params[:page_id])

    authorize! :read, page

    render 'api/pages/index', locals: {
      pages: [ page ]
    }
  end

  def update
    page = Page.find(params[:page_id])
    space = page.folder.space

    authorize! :author, space,
      message: "You need to be an editor of this space to edit pages."

    xparams = params.require(:page).permit(:title, :content, :browsable, :folder_id)

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

    render 'api/pages/index', locals: {
      pages: [ page ]
    }
  end

  def destroy
    page = Page.find(params[:page_id])

    authorize! :delete, page,
      message: "You can not remove pages authored by someone else."

    unless page.destroy
      halt! 500, page.errors
    end

    head 204
  end
end
