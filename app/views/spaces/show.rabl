object @space

extends "spaces/_show"

node(:root_folder) do |s|
  partial "folders/_show", object: s.root_folder
end

node(:folders) do |s|
  s.folders.map { |f| partial "folders/_show_with_pages", object: f }
end

node(:memberships) do |space|
  space.users.map do |user|
    {
      id:       user.id,
      nickname: user.nickname,
      role:     space.role_of(user),
      contributions: {
        nr_pages: space.pages.where({ user_id: user.id }).count,
        nr_folders: space.folders.where({ user_id: user.id }).count
      }
    }.tap do |hash|
      if respond_to?(:gravatar_url)
        hash[:gravatar] = gravatar_url(user.gravatar_email, :size => 24)
      end
    end
  end
end

node(:preferences) do |space|
  space.preferences
end