module Fixtures
  class FolderFixture < Fixture
    def build(space, params = {})
      # attrs = accept(params, )
      attrs = {
        title: 'Some Folder',
        pretty_title: nil,
        browsable: true,
        # user: space.user,
        user_id: space.user_id,
        # folder: nil,
        folder_id: nil
      }.with_indifferent_access.merge(params)

      space.folders.create(attrs)
    end
  end
end