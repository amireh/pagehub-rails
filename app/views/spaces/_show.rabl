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
  __path = [ space.user.nickname, space.pretty_title ]

  {
    href: space.href,
    url:  user_space_url(space.user, space),

    actions: {
      edit: user_space_edit_url(space.user.nickname, space.pretty_title),
      settings: user_space_settings_url(space.user, space),
    },

    # pages: space_pages_url(*__path),
    new_page: new_space_resource_url(*__path)
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
