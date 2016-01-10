json.memberships memberships do |membership|
  json.partial! 'api/space_users/show', object: membership
end