module Rack::Test
  class Session
    alias_method :_post, :post
    def post(uri, params = {}, env = {}, &block)
      _post(uri, prepare_params(params), env, &block)
    end

    alias_method :_put, :put
    def put(uri, params = {}, env = {}, &block)
      _put(uri, prepare_params(params), env, &block)
    end

    alias_method :_patch, :patch
    def patch(uri, params = {}, env = {}, &block)
      _patch(uri, prepare_params(params), env, &block)
    end

    private

    def prepare_params(params)
      @headers['Content-Type'] =~ /json/ ? params.to_json : params
    end
  end
end