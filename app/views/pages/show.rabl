object @page

extends "pages/_show"

attributes :content

node(:nr_revisions) do |page|
  page.revisions.count
end

# child(:folder) do |f|
#   partial "folders/_show", object: @page.folder
# end

node(:media) do |page|
  partial "pages/_media", object: page
end