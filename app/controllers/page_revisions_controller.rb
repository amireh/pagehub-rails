class PageRevisionsController < ApplicationController
  respond_to :html

  before_filter :require_user

  def index
    @page = require_page
    @space = @page.space

    halt! 403 if current_ability.cannot?(:edit, @page)

    respond_to do |format|
      format.html
    end
  end

  def show
    @page = require_page
    @rv = require_revision(@page)

    @prev_rv = @rv.prev
    @next_rv = @rv.next

    halt! 403 if current_ability.cannot?(:edit, @page)

    respond_to do |format|
      format.html
    end
  end

  def rollback
    @page = require_page
    @space = @page.space
    @rv = require_revision(@page)

    params.permit(:confirmed)

    respond_to do |format|
      format.html do
        if params[:confirmed] != "do it"
          flash[:error] = "Will not roll-back until you have confirmed your action."
          return redirect_back_to_revision @page, @rv
        end

        unless @page.rollback(@rv)
          flash[:error] = "Page failed to rollback: #{@page.collect_errors}"
          return redirect_back_to_revision @page, @rv
        end

        flash[:notice] = "Page has been restored to version #{@rv.pretty_version}."

        redirect_back_to_revision @page, @rv
      end
    end
  end

  private

  def require_page
    Page.find(params[:page_id]).tap do |page|
      authorize! :author, page.space
    end
  end

  def require_revision(page)
    page.revisions.find(params[:revision_id])
  end

  def redirect_back_to_revision(page, rv)
    redirect_to page_revision_url(page.id, rv.id)
  end
end