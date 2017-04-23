json.id             page.id.to_s
json.folder_id      page.folder_id.to_s
json.user_id        page.user_id.to_s
json.title          ERB::Util.h(page.title)
json.pretty_title   ERB::Util.h(page.pretty_title)
json.browsable      !!page.browsable
json.encrypted      !!page.encrypted
json.content        page.content
json.digest         page.digest || nil