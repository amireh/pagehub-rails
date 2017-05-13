json.spaces spaces do |space|
  json.id               space.id.to_s
  json.title            ERB::Util.h(space.title)
  json.pretty_title     ERB::Util.h(space.pretty_title)
  json.brief            ERB::Util.h(space.brief)
  json.is_public        space.is_public
  json.preferences      space.preferences
  json.fqid             ("#{space.creator.nickname}/#{space.pretty_title}")
end