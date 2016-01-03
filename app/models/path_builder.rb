class PathBuilder
  def for_page(page)
    folder_ancestors(page.folder)
      .concat([ page ])
      .map(&:pretty_title)
      .map { |s| Addressable::URI.unencode(s) }
      .join('/')
  end

  def for_folder(folder)
    folder_ancestors(folder)
      .map(&:pretty_title)
      .map { |s| Addressable::URI.unencode(s) }
      .join('/')
  end

  def folder_ancestors(folder)
    [].tap do |ancestors|
      loop do
        break if folder.nil? || folder.root_folder?

        ancestors.unshift folder

        folder = folder.folder
      end
    end
  end
end