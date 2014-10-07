module RSpec
  module RealtimeMessageMatchers
    class Publish
      def initialize(code, options)
        @code = code
        @options = options
      end

      def matches?(*args)
        @message = get_messages.detect do |message|
          message[:code].to_s == @code.to_s
        end

        @message.present?
      end

      def failure_message
        <<-MSG
        Expected RT message '#{@code}' to be published, but it was't.
        Here is a list of the messages that were published:
          #{get_messages.map { |m| m[:code] } }
        MSG
      end
      private

      def get_messages
        RSpec::RTMessageInterceptor.instance.messages
      end
    end

    def publish(message_code, options={})
      Publish.new(message_code, options)
    end

  end
end

RSpec.configure do |config|
  config.include RSpec::RealtimeMessageMatchers
end
