class Api::V1::PagesController < ApiController
  def index
    folder = Folder.find(params[:current_folder_id])

    authorized_action! :read, folder

    ams_expose_object folder.pages.includes(:user)
  end

  def create
    folder = Folder.find(params[:current_folder_id])
    space = folder.space

    authorize! :author, space,
      :message => 'You need to be an editor of this space to create pages.'

    authorize! :author_more, space,
      :message => 'You can not create any more pages in this space.'

    accepts :title, :content, :browsable

    page = folder.pages.create api.parameters({
      user_id: current_user.id
    })

    unless page.valid?
      halt! 422, page.errors
    end

    expose page
  end

  def show
    page = Page.find(params[:page_id])

    authorized_action! :read, page

    ams_expose_object page
  end

  def update
    page = Page.find(params[:page_id])
    space = page.folder.space

    authorize! :author, space,
      message: "You need to be an editor of this space to edit pages."

    accepts :title, :content, :browsable, :folder_id

    if new_folder_id = api.get(:folder_id)
      new_folder = Folder.find(new_folder_id)

      if new_folder.space != space
        halt! 422, "You can only move pages between folders within the same space."
      end
    end

    if new_content = api.get(:content)
      PageHub::Markdown::mutate! @api[:optional][:content]

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

    unless page.update(api.parameters)
      halt! 422, page.errors
    end

    expose page
  end
end
