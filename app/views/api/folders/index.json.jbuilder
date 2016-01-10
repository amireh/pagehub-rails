json.folders folders do |folder|
  json.partial! 'api/folders/show', object: folder
end