collection @spaces, :root => "spaces", :object_root => false

extends "spaces/_show"

node(:role) do |space| space.space_users.detect { |m| m.user_id == current_user.id }.role end
# node(:nr_pages) do |s| s.pages.count end
# node(:nr_folders) do |s| s.folders.count end
node(:nr_members) do |space| space.space_users.size end