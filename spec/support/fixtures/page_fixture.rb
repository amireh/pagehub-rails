module Fixtures
  class PageFixture < Fixture
    def build(folder, params = {})
      attrs = accept(params, {
        title: nil,
        pretty_title: nil,
        content: '',
        browsable: true,
        user_id: folder.user_id
      }.with_indifferent_access)

      folder.pages.create(attrs)
    end
  end
end