json.id             object.id.to_s
json.folder_id      object.folder_id.to_s
json.title          ERB::Util.h(object.title)
json.pretty_title   ERB::Util.h(object.pretty_title)
json.browsable      object.browsable
json.content        object.content

json.url            api_v1_folder_page_url(object.folder.space_id, object)
json.href           generic_resource_url(object.href)

json.edit_url       edit_page_url(object.id)

json.revision_count object.revisions.count
json.revisions_href page_revisions_url(object.id)