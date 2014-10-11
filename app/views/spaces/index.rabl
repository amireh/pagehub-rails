collection @spaces, :root => "spaces", :object_root => false

extends "spaces/_show"

node(:role) do |space| space.space_users.detect { |m| m.user_id == current_user.id }.role end
node(:nr_pages) do |space| space.pages.size end
node(:nr_folders) do |space| space.folders.size end
node(:nr_members) do |space| space.space_users.size end