object @space

attributes :id, :title, :brief, :is_public

node(:meta) do |s|
  {
    # nr_pages:   s.pages.size,
    # nr_folders: s.folders.size,
    # nr_members: s.space_users.size
  }
end

node(:media) do |space|
  {
    href: user_space_url(space.user.nickname, space),
    url:  user_space_url(space.user, space),

    actions: {
      edit: user_space_editor_url(space.user, space),
      settings: user_space_settings_url(space.user, space),
    },

    # pages:  {
    #   url: space.url(true) + '/pages'
    # },
    # folders: {
    #   url: space.url(true) + '/folders'
    # },
    # name_availability_url: space.user.url + '/spaces/name'
  }
end

child(:creator => :creator) do |u|
  # partial "/users/_show", object: u
  attributes :id, :nickname
end
