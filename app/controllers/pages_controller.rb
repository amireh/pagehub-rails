class PagesController < ApplicationController
  def edit
    @page = Page.find(params[:id])
    @space = @page.space

    if current_ability.cannot?(:edit, @page)
      halt! 403
    end

    # layout false
    render layout: false
  end
end