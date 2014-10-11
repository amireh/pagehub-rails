object @user

attributes :id, :name, :nickname, :email, :gravatar_email

node(:media) do |user|
  {
    href: user_url(user.nickname),
    url: api_user_url(user.id),
    spaces: api_user_spaces_url(user.id),
    name_availability: api_user_nickname_availability_url(),
    resend_confirmation_instructions: api_user_resend_confirmation_instructions_url()
  }
end

node(:nr_pages) do |user| user.pages.count end
# node(:nr_folders) do |u| u.folders.count end

node(:spaces) do
  partial "/spaces/index", object: @user.spaces.includes(:space_users, :folders, :pages, :user)
end

node(:preferences) do |s|
  s.preferences
end