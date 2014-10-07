object @user

attributes :id, :name, :nickname

node(:media) do |user|
  {
    href: user_url(user),
    spaces: {
      url:  user_spaces_url(user)
    }
  }
end

node(:nr_pages) do |u| u.pages.count end
node(:nr_folders) do |u| u.folders.count end

node(:spaces) do
  partial "/spaces/index", object: @user.public_spaces(current_user)
end

node(:preferences) do |s|
  s.preferences
end