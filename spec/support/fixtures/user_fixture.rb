module Fixtures
  class UserFixture < Fixture
    def self.password
      'helloWorld123'
    end

    def build(params = {})
      attrs = accept(params, json_fixture('user.json').merge(nickname: ''))

      if attrs[:nickname].blank?
        attrs[:nickname] = "random_#{SecureRandom.base64[0..12].gsub(/\W/, '_').downcase}"
      end

      user = User.create!(attrs)
      user
    end
  end # UserFixture
end