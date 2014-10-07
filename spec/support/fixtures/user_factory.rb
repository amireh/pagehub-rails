module Fixtures
  class UserFactory < Factory
    def self.password
      'helloWorld123'
    end

    def build(params = {})
      attrs = accept(params, json_fixture('user.json'))

      if user = User.create!(attrs)
        user.accounts.create
      end

      user
    end
  end # UserFactory
end