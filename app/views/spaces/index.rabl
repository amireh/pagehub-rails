collection @spaces, :root => "spaces", :object_root => false

extends "spaces/_show"

node(:role) do |space| space.role_of(current_user) end
# node(:nr_pages) do |s| s.pages.count end
# node(:nr_folders) do |s| s.folders.count end
node(:nr_members) do |space| space.space_users.count end