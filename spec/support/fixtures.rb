module Fixtures
  class << self
    attr_accessor :fixtures

    def [](type)
      self.fixtures ||= {}
      begin
        self.fixtures[type.to_sym].new
      rescue
        raise "Unknown fixture type: #{type}"
      end
    end

    def register(name, factory)
      self.fixtures ||= {}
      self.fixtures[name.to_sym] = factory
    end

    def teardown

      User.destroy_all

      [ User ].each do |r|
        unless r.all.length == 0
          raise "[ERROR] Cleanup: expected #{r} to contain 0 resources, but got #{r.all.length}"
        end
      end
    end

    def gen_id
      @@id ||= 0
      @@id += 1
    end
  end
end # Fixtures

module Fixtures
  class Factory
    attr_accessor :params

    def self.inherited(instance)
      fixture_klass = instance.name.demodulize.gsub('Fixture', '').underscore

      Fixtures.register fixture_klass, instance
    end

    def cleanup
      raise "Must be implemented by child."
    end

    def build(params = {})
      raise "Must be implemented by child."
    end

    def generate_salt(r = 3)
      (Base64.urlsafe_encode64 Random.rand(1234 * (10**r)).to_s(8)).to_s.sanitize
    end
    alias_method :salt, :generate_salt
    alias_method :tiny_salt, :generate_salt

    def accept(params, p = @params)
      params.each_pair { |k,v|
        next unless p.has_key?(k)

        if v.is_a?(Hash)
          accept(v, p)
          next
        end

        p[k] = v
      }
      p
    end
  end
end

RSpec.configure do |config|
  config.before :each do
    Fixtures.teardown
  end
end