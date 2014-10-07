module RSpec
  module APIResponseMatchers
    class Failure
      def initialize(http_rc = 400, *keywords)
        @http_rc  = http_rc
        @keywords = (keywords || []).flatten
        @raw_keywords = @keywords.dup
      end

      def matches?(api_rc)
        if api_rc.is_a?(Proc)
          api_rc = api_rc.yield
        end

        @api_rc = api_rc

        return false if api_rc.http_rc != @http_rc
        return false if api_rc.status  != :error

        if @keywords.empty?
          return true if api_rc.messages.empty?
          return false
        end

        if @keywords.size == 1
          @keywords = @keywords.first

          unless @keywords.is_a?(Regexp)
            @keywords = @keywords.split(/\s/)
          end
        end

        unless @keywords.is_a?(Regexp)
          @keywords = Regexp.new(@keywords.join('.*'), 'i')
        end

        api_rc.messages.any? { |m| m.match(@keywords) }
      end # Failure#matches

      def failure_message
        m = "Expected: \n"

        if @api_rc.status != :error
          m << "* The API response status to be :error, but got #{@api_rc.status}\n"
        end

        if @api_rc.http_rc != @http_rc
          m << "* The HTTP RC to be #{@http_rc}, but got #{@api_rc.http_rc}\n"
        end

        formatted_keywords = @raw_keywords.join(' ')

        if @raw_keywords.any? && @api_rc.messages.any?
          m << "* One of the following API response messages: \n"
          m << @api_rc.messages.collect.with_index { |m, i| "\t#{i+1}. #{m}" }.join("\n")
          m << "\n  to be matched by the keywords: #{formatted_keywords}\n"

        elsif @raw_keywords.any? && @api_rc.messages.empty?
          m << "* The API response to contain some messages (got 0) and for at least\n" <<
               "  one of them to match the keywords #{formatted_keywords}\n"

        elsif @raw_keywords.empty? && @api_rc.messages.any?
          m << "* The API response to contain no messages, but got: \n"
          m << @api_rc.messages.collect.with_index { |m, i| "\t#{i+1}. #{m}" }.join("\n")
          m << "\n"
        end

        m
      end
    end # Failure

    class Success
      def initialize(http_rc)
        @http_rc = http_rc
      end

      def matches?(api_rc)
        if api_rc.is_a?(Proc)
          api_rc = api_rc.yield
        end

        @api_rc = api_rc

        return false unless @http_rc.include?(api_rc.http_rc)
        return false if api_rc.status  != :success

        true
      end

      def failure_message
        m = "Expected:\n"

        if @api_rc.status != :success
          m << "* The API response status to be :success, but got #{@api_rc.status}\n"
        end

        if @api_rc.http_rc != @http_rc
          m << "* The HTTP RC to be #{@http_rc}, but got #{@api_rc.http_rc}\n"
        end

        if @api_rc.messages.any?
          m << "* The API response messages to be empty, but got: \n"
          m << @api_rc.messages.collect.with_index { |m, i| "\t#{i+1}. #{m}" }.join("\n")
          m << "\n"
        end

        m
      end
    end

    def fail(http_rc = 400, *keywords)
      Failure.new(http_rc, keywords)
    end

    def succeed(http_rc = 200..205)
      http_rc = http_rc.respond_to?(:to_a) ? http_rc.to_a : [ http_rc ]
      Success.new(http_rc.flatten)
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::APIResponseMatchers
end
