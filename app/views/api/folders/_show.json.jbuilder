json.id           object.id.to_s
json.folder_id    object.folder_id.to_s
json.title        ERB::Util.h(object.title)
json.pretty_title ERB::Util.h(object.pretty_title)
json.browsable    object.browsable
json.url          api_v1_space_folder_url(object.space_id, object)
json.href         generic_resource_url(object.href)

json.links do
  json.pages api_v1_folder_pages_url(object)
end