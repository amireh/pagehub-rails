json.user_id        object.user_id.to_s
json.space_id       object.space_id.to_s
json.role           SpaceUser.role_name(object.role)
json.user_nickname  object.user.nickname
json.gravatar       gravatar_url(object.user.gravatar_email)
json.page_count     object.space.pages.select { |r| r.user_id == object.user_id }.size
json.folder_count   object.space.folders.select { |r| r.user_id == object.user_id }.size