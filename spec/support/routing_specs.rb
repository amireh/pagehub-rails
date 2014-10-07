shared_examples_for "routing specs" do
  after do
    Rails.application.reload_routes!
  end

  class TestResource
  end

  class TestsController < ApplicationController
    include Rack::API::Resources
    include Rack::API::Parameters
  end

  class RouteBuilder
    %w[ get post put patch delete ].map(&:to_sym).each do |http_verb|
      define_method http_verb do |url, &block|
        method_name = "some_method_#{UUID.generate.underscore}".to_sym

        TestsController.class_eval do
          send :define_method, method_name, &block
        end

        Rails.application.routes.draw do
          scope({ controller: :tests }) do
            send http_verb, url, action: method_name
          end
        end
      end
    end
  end

  let :router do
    RouteBuilder.new
  end
end