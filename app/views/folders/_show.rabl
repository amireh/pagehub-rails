object @folder

attributes :id, :title, :pretty_title, :browsable

node :media do |folder|
  {
    url: space_folder_url(folder.space.user.nickname, folder.space.pretty_title, folder.pretty_title),
    href: folder.href,
  }
end

child(:folder => :parent) do |parent|
  attributes :id
end