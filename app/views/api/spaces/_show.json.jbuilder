json.id               object.id.to_s
json.url              api_user_space_url(object.user, object)
json.title            ERB::Util.h(object.title)
json.pretty_title     ERB::Util.h(object.pretty_title)
json.brief            ERB::Util.h(object.brief)
json.is_public        object.is_public
json.preferences      object.preferences

json.creator do
  json.id       object.user.id.to_s
  json.nickname object.user.nickname.to_s
  json.href     user_path(object.user.nickname)
end

json.folders object.folders do |folder|
  json.partial! "api/folders/show", object: folder
end

json.pages object.pages do |page|
  json.partial! "api/pages/show", object: page, include_revisions: false
end

json.memberships object.space_users do |user|
  json.partial! "api/space_users/show", object: user
end

json.links do
  json.edit         user_space_edit_url(object.user.nickname, object.pretty_title)
  json.folders      api_space_folders_url(object)
  json.memberships  api_user_space_memberships_url(object.user_id, object)
  json.settings     user_space_settings_url(object.user.nickname, object.pretty_title)
end