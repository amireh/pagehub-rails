module Fixtures
  class FolderFixture < Fixture
    def build(space, params = {})
      attrs = accept(params, {
        title: 'Some Folder',
        browsable: true,
        # user: space.user,
        user_id: space.user_id,
        # folder: nil,
        folder_id: nil
      }.with_indifferent_access)

      space.folders.create(attrs)
    end
  end
end