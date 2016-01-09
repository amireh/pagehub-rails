json.spaces spaces do |space|
  json.partial! 'api/spaces/show', object: space
end