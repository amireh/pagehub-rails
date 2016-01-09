class PagesController < ApplicationController
  def edit
    @page = Page.find(params[:id])
    @space = @page.space

    if current_ability.cannot?(:edit, @page)
      halt! 403
    end

    respond_to do |format|
      format.html do
        render layout: false
      end
    end
  end
end