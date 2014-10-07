module ErrorRenderer
  extend ActiveSupport::Concern

  included do |base|
    rescue_from StandardError, with: :render_internal_error
    rescue_from ActionDispatch::ParamsParser::ParseError, with: :render_parser_error
    rescue_from Rack::API::Error, with: :render_error
  end

  def render_internal_error(error)
    NewRelic::Agent.agent.error_collector.notice_error(error, env)

    if Rails.env.test?
      raise error
    elsif Rails.env.development?
      puts error.message
      puts error.backtrace
    end

    render_error Rack::API::Error.new(500, error.message)
  end

  def render_not_found_error(error)
    render_error Rack::API::Error.new(404)
  end

  def render_parser_error(error)
    render_error Rack::API::Error.new(400, "Malformed JSON.")
  end

  def render_error(error)
    response.status = error.status

    # Render a "No Content" response
    if error.status == 204
      return head :no_content
    end

    render json: error
  end
end