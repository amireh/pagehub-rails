class UsersController < ApplicationController
  include Rack::API::Parameters

  respond_to :html

  before_filter :require_user

  def dashboard
    @user = current_user
  end

  def show
    redirect_to action: :dashboard
  end
end
