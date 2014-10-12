module FolderContainable
  extend ActiveSupport::Concern

  ERR_NAME_UNAVAILABLE = 'You already have a similarily named page (or folder) in that folder.'

  included do |base|
    base.class_eval do
      belongs_to :folder

      attr_writer :href

      validate :deny_reserved_titles, if: :title_changed?
      validate :ensure_hierarchical_resource_title_uniqueness, if: :title_changed?
    end
  end

  # Make sure that resources in the root folder are not titled with one of the
  # reserved titles, which are basically words that we use for special pages
  # like "settings" or "edit".
  #
  # See PageHub::RESERVED_RESOURCE_TITLES for the list of reserved titles.
  def deny_reserved_titles
    if in_root_folder? && !PageHub.resource_title_available?(self.title)
      errors.add :pretty_title, "That title is reserved for internal usage."
      return false
    end
  end

  # Make sure there are no siblings with the same title as this resource.
  def ensure_hierarchical_resource_title_uniqueness
    bail = -> {
      errors.add :title, ERR_NAME_UNAVAILABLE
      return false
    }

    return if !self.folder # forget it if it's the root folder

    if self.folder.pages.titled(self.title).where.not(id: self.id).any?
      return bail.call()
    elsif self.folder.folders.titled(self.title).any?
      return bail.call()
    end
  end

  def in_root_folder?
    raise NotImplementedError
  end
end