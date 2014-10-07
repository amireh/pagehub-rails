object @user

attributes :id, :name, :nickname, :email, :gravatar_email

node(:media) do |u|
  {
    href:   user_url(u),
    url:    user_path(u),
    spaces: {
      url:  user_path(u) + '/spaces'
    },
    name_availability_url: '/users/name'
  }
end

# node(:nr_pages) do |u| u.pages.count end
# node(:nr_folders) do |u| u.folders.count end

# node(:spaces) do
#   partial "/spaces/index", object: @user.spaces
# end

node(:preferences) do |s|
  s.preferences
end