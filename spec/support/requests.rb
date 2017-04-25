module Support
  module Requests
    extend ActiveSupport::Concern

    def payload
      HashWithIndifferentAccess.new(JSON.parse(response.body))
    end

    def api_request_headers(user)
      {
        "Accept" => Mime::JSON.to_s,
        # "Content-Type" => Mime::JSON.to_s
      }.merge(auth_header(user))
    end

    def auth_header(user)
      {
        'Authorization' => ActionController::HttpAuthentication::Basic.encode_credentials(user.email, user.password)
      }
    end
  end
end