module Support
  module Controllers
    def set_json_headers
      request.headers["Accept"] = request.headers["Content-Type"] = Mime::JSON.to_s
    end

    def set_auth_headers(email, password)
      request.headers.merge!(auth_header(email, password))
    end

    def auth_header(email, password)
      {
        "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials(email, password)
      }
    end

    def login_as(user)
      set_json_headers
      set_auth_headers(user.email, Support::Factories::DEFAULT_PASSWORD)
    end

    def response_json
      return @response_json if @last_response.equal?(response)
      @last_response = response
      @response_json = JSON.parse(response.body, symbolize_names: true)
    end
  end
end