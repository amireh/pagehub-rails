json.users users do |user|
  json.partial! 'api/users/show', object: user
end