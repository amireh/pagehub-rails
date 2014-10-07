module PageHub
  module Config
    class << self
      cattr_accessor :defaults

      def init(file = Rails.root.join('config', 'default_preferences.json'))
        @@defaults = load(file)
      end

      def load(file)
        JSON.parse(File.read(file))
      end

      def defaults
        @@defaults ||= nil
        @@defaults || init()
      end

      def get(*key)
      end
    end
  end
end