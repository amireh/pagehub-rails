module Rack
  module Test
    class APIResponse
      attr_reader :rr, :body, :status, :messages, :http_rc

      def initialize(rack_response)
        @rr = rack_response
        @http_rc = @rr.status
        @body = ''

        if rack_response.headers['Content-Type'] =~ /json/
          @body = begin
            JSON.parse(@rr.body.empty? ? '{}' : @rr.body)
          rescue JSON::ParserError => e
            raise "Invalid API response; body is not JSON: '%s'\nException: %s" % [
              @rr.body, e.message
            ]
          end
        end

        if @body.respond_to?(:with_indifferent_access)
          @body = @body.with_indifferent_access
        end

        @status   = :success
        @messages = []

        unless blank?
          if @body.is_a?(Hash)
            @status   = @body["status"].to_s.to_sym  if @body.has_key?("status")
            @messages = @body["messages"]       if @body.has_key?("messages")
          elsif @body.is_a?(Array)
            @messages = @body
          else
            @messages = @body
          end
        end
      end

      def blank?
        @body.empty?
      end

      def succeeded?
        !blank? && @status == :success
      end

      def failed?
        !blank? && @status == :error
      end
    end # APIResponse
  end # Test
end # Rack
