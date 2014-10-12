class ApplicationController < ActionController::Base
  include ErrorRenderer
  include JsonRenderer

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :expose_preferences

  def landing
    if current_user.present?
      redirect_to controller: :users, action: :dashboard
    else
      redirect_to controller: :guests, action: :index
    end
  end

  # Catch 404s
  def rogue_route
    # halt! 404 if json_request?
    respond_to do |format|
      format.html do
        render file: '/public/404.html', status: :not_found, layout: false
      end

      format.json do
        halt! 404
      end

      format.any do
        render text: 'Not Found', status: :not_found, content_type: Mime::TEXT
      end
    end
  end

  protected

  def require_user
    authenticate_user!
  end

  def js_env(hash)
    return if json_request?

    @js_env ||= {}
    @js_env.merge!(hash)
  end

  def expose_preferences
    if current_user
      current_user_json = ams_render_object current_user, UserSerializer

      js_env({
        app_preferences: PageHub::Config.defaults,
        current_user: current_user_json
      })
    end
  end

  # Halt the execution of the current controller handler and respond with
  # the specified HTTP Status Code and a given message.
  #
  # See Rack::API::Error#initialize for the arguments.
  def halt!(status, message = nil)
    raise Rack::API::Error.new(status, message)
  end

  # Respond with a 204 No Content, useful for DELETE operations, or ones that
  # request no-content (such as requests with the [:headless] parameter).
  #
  # @warning
  # Calling this method halts the execution.
  def no_content!
    halt! 204
  end

  def require_json_format
    accept = request.headers['HTTP_ACCEPT'] || ''

    unless ['*', '*/*' ].include?(accept) || accept =~ /json/
      render :text => 'Not Acceptable', status: 406
    end
  end

  def json_request?
    (request.headers['HTTP_ACCEPT'] || '') =~ /json/
  end
end
