module Fixtures
  class SpaceFixture < Fixture
    def build(user, params = {})
      attrs = accept(params, { title: 'Some Space' }.with_indifferent_access)
      user.owned_spaces.create(attrs)
    end
  end
end