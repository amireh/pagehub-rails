json.pages pages do |page|
  json.partial! 'api/pages/show', object: page
end