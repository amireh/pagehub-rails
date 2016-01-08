class PageRevisionsController < ApplicationController
  def index
    @page = Page.find(params[:page_id])
    @space = @page.space

    halt! 403 if current_ability.cannot?(:edit, @page)
  end

  def show
    @page = Page.find(params[:page_id])

    @rv = @page.revisions.find(params[:id])

    @prev_rv = @rv.prev
    @next_rv = @rv.next

    halt! 403 if current_ability.cannot?(:edit, @page)
  end
end