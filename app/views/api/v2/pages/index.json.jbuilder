json.pages pages do |page|
  json.partial! 'api/v2/pages/show', page: page
end