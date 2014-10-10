module Fixtures
  class UserFixture < Fixture
    def self.password
      'helloWorld123'
    end

    def build(params = {})
      attrs = accept(params, json_fixture('user.json'))
      user = User.create!(attrs)
      user
    end
  end # UserFixture
end