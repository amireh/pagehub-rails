class ApiController < ApplicationController
  respond_to :json

  before_filter :require_json_format
  before_filter :accept_authenticity

  # we will be doing this in #accept_authenticity because we need to have
  # accepted basic auth (for now) before we perform this check (we skip it
  # for OTR calls)
  skip_before_filter :verify_authenticity_token

  protected

  # @override
  #
  # - Accept "self" as a user_id to point to the current user
  # - Skip Devise/warden/session authentication
  def require_user
    @user = if params[:user_id] == 'self'
      current_user
    else
      User.find(params[:user_id])
    end
  end

  # Authenticate through HTTP Basic Auth or X-Access-Token if passed.
  def accept_authenticity
    authenticate_with_http_basic do |email, password|
      user = User.find_by(email: email, provider: 'pagehub')

      if user && user.valid_password?(password)
        @current_user = user
      end
    end

    warden.custom_failure! if performed?

    halt! 401 unless current_user.present?
    verify_authenticity_token unless otr_api_call?
  end

  def authorized_action!(sought_permission, object, options={})
    if current_ability.cannot?(sought_permission.to_sym, object)
      halt! 403, options[:message]
    end
  end

  # TODO: switch to using API tokens instead of basic auth then we can drop
  # the header test
  def otr_api_call?
    current_user.present? && request.headers['X-0-Hub'] == '1'
  end

  alias_method :authorize!, :authorized_action!
end
