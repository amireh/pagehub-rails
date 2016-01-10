module Support
  module Factories
    DEFAULT_PASSWORD = "helloWorld123".freeze

    def a_user(params = {})
      attrs = {
        "name" => "Mysterious Mocker",
        "email" => "very@mysterious.com",
        "password" => Factories::DEFAULT_PASSWORD,
        "password_confirmation" => Factories::DEFAULT_PASSWORD,
        "nickname" => ""
      }.merge(params).with_indifferent_access

      if attrs[:nickname].blank?
        attrs[:nickname] = "random_#{SecureRandom.base64[0..12].gsub(/\W/, '_').downcase}"
      end

      User.create!(attrs)
    end

    def a_space(user = a_user, params = {})
      user.owned_spaces.create({
        title: Space::DEFAULT_TITLE
      }.with_indifferent_access.merge(params))
    end

    def a_space_with_editor(user = a_user, params = {})
      a_space(user, params).tap do |space|
        space.space_users.creators.create({
          user_id: user.id
        })
      end
    end

    def a_folder(space = a_space, params = {})
      space.folders.create({
        title: 'Some Folder',
        pretty_title: nil,
        browsable: true,
        user_id: space.user_id,
        folder_id: nil
      }.with_indifferent_access.merge(params))
    end

    def a_page(folder = a_folder, params = {})
      folder.pages.create({
        title: nil,
        pretty_title: nil,
        content: '',
        browsable: true,
        user_id: folder.user_id
      }.with_indifferent_access.merge(params))
    end
  end
end