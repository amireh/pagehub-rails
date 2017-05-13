json.spaces spaces do |space|
  json.id               space.id.to_s
  json.title            ERB::Util.h(space.title)
  json.pretty_title     ERB::Util.h(space.pretty_title)
  json.brief            ERB::Util.h(space.brief)
  json.is_public        space.is_public

  if defined? include_creator && include_creator == true
    json.creator do
      json.id       space.user.id.to_s
      json.nickname space.user.nickname.to_s
    end

    json.links do
      json.edit     user_space_edit_url(space.user.nickname, space.pretty_title)
    end
  end

  if defined? include_memberships && include_memberships == true
    json.memberships space.space_users do |membership|
      json.user_id  membership.user_id.to_s
      json.role     membership.role_name.to_s
    end
  end
end