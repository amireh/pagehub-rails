class ApiController < ApplicationController
  include Rack::API::Parameters

  respond_to :json
  before_filter :require_json_format, only: [ :update ]
end
