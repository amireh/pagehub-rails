json.id             object.id.to_s
json.name           ERB::Util.h(object.name)
json.nickname       object.nickname
json.gravatar_email object.gravatar_email
json.url            api_user_url(object.id)
json.href           user_url(object.nickname)

json.email          object.email if can?(:view_private_data, object)
json.preferences    object.preferences if can?(:view_preferences, object)

json.links do
  json.spaces                           api_user_spaces_url(object.id)
  json.name_availability                api_user_nickname_availability_url
  json.resend_confirmation_instructions api_user_resend_confirmation_instructions_url
end