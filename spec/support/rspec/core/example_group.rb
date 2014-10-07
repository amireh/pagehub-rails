module RSpec
  module Core
    class ExampleGroup
      class << self
        alias_method :scenario, :it
      end
    end
  end
end