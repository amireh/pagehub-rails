class Folder < ActiveRecord::Base
  include Titlable
  include FolderContainable

  DEFAULT_FOLDER = 'None'

  # TODO: add index
  default_scope { order(pretty_title: :asc) }

  belongs_to :space
  belongs_to :user

  has_many :folders, dependent: :destroy
  has_many :pages, dependent: :destroy

  alias_method :creator, :user

  validates_presence_of :title,
    message: 'You must provide a title for this folder.'

  validate :validate_hierarchy, if: :folder_id_changed?

  before_save :set_defaults
  before_validation :ensure_parent_folder

  def create_homepage
    self.pages.first_or_create({ title: Page::README_PAGE }) do |page|
      page.user_id = self.user_id
    end
  end

  def has_homepage?
    !!homepage
  end

  def homepage
    self.pages.where(title: [ 'Home', Page::README_PAGE ]).first
  end

  def href
    if @href
      @href
    elsif self.association(:space).loaded? && !@href
      build_href(self, space.folders, space.href)
    else
      if root_folder?
        space.href
      else
        "/#{folder.href}/#{pretty_title}"
      end
    end
  end

  def root_folder?
    self.folder_id == nil
  end

  def in_root_folder?
    root_folder? || self.folder.root_folder?
  end

  def serialize
    {
      id: id,
      title: title,
      pages: pages.map(&:serialize),
      parent: self.folder_id
    }
  end

  def browsable_by?(user)
    return true if space.member?(user)
    return false if !self.browsable

    if folder
      folder.browsable_by?(user)
    else
      true
    end
  end

  def deletable_by?(user)
    creator = self.user

    if !space.is_member?(user)
      [ false, "You are not authorized to delete folders in this space." ]
    elsif creator.id != user.id
      [ false, "You are not authorized to delete folders created by others." ]
    elsif self.folders.where.not(user_id: creator.id).any?
      [ false, "The folder contains others created by someone else, they must be removed first." ]
    else
      true
    end
  end

  def empty?(scope = :public)
    self.folders.empty? && self.pages.browsable.empty?
  end

  def is_child_of?(other_folder)
    return false if self.root_folder?

    # is that folder our parent?
    if self.folder_id == other_folder.id
      true
    else
      # is our parent contained within that folder?
      self.folder.is_child_of?(other_folder)
    end
  end

  def siblings
    if !folder
      return []
    end

    folder.folders.where("id != #{self.id}")
  end

  def descendants(with_pages = false)
    folders.collect { |f| f.descendants }.flatten + folders + (with_pages ? pages : [])
  end

  # @return [Boolean]
  #   True if this folder contains no sub-folders or pages that have the given
  #   title.
  def title_available?(raw_title, folder_id=nil)
    title = StringUtils.sanitize(raw_title.to_s)

    self.folders.where({ pretty_title: title }).none? &&
    self.pages.where({ pretty_title: title }).none?
  end

  private

  def set_defaults
    self.browsable = true if self.browsable.nil?
  end

  def ensure_parent_folder
    # attach to the root folder if no parent was specified
    if folder_id.nil? && self.title != DEFAULT_FOLDER
      self.folder_id = space.root_folder.id
    end
  end

  # Checks for placement of a folder
  def validate_hierarchy
    if folder
      # prevent the folder from being its own parent
      if folder.id == self.id then
        errors.add :folder_id, "You cannot add a folder to itself!"

      # or a parent being a child of one of its children
      elsif folder.is_child_of?(self) then
        errors.add :folder_id, "Folder '#{title}' currently contains '#{folder.title}', it cannot become its child."
      elsif folder.space != self.space then
        errors.add :folder_id, "Parent folder is not in the same space!"
      end
    else
      # no folder?
      if space.folders.count > 1 && title != DefaultFolder
        errors.add :folder_id, "A folder must be set inside another."
      end
    end

    errors.empty?
  end

  # Pre-destroy hook:
  #
  # If this folder is attached to another, we will move all its children pages
  # and folders to that parent, otherwise they are orphaned into the root
  # folder.
  #
  # TODO: this isn't used anywhere, is it?
  def nullify_references(context = :default)
    new_parent = self.folder

    if new_parent
      pages.where({ title: Page::README_PAGE }).update({ title: "#{self.title} - README" })

      pages.update_all(folder_id: new_parent.id)
      folders.update_all(folder_id: new_parent.id)
    end

    self.reload
  end

  # A heavily optimized href builder that will utilize an eagerly loaded set of
  # folders (e.g, Space#folders).
  #
  # This will set the @href attribute on this folder and its ancestry chain.
  #
  # @return [String]
  def build_href(folder, folder_set, base)
    parent_id = folder[:folder_id]

    if parent_id.present?
      parent = folder_set.detect { |folder| folder[:id] == parent_id }

      if parent
        base = build_href(parent, folder_set, base)
      end

      folder.href = [ base, folder[:pretty_title] ].join('/')
    else
      folder.href = base
    end
  end
end
