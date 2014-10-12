class Api::V1::PagesController < ApiController
  def index
    folder = Folder.find(params[:folder_id])

    authorized_action! :read, folder

    ams_expose_object folder.pages.includes(:user)
  end

  def show
    page = Page.find(params[:page_id])

    authorized_action! :read, page

    ams_expose_object page
  end
end
