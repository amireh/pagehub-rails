class Folder < ActiveRecord::Base
  include Titlable

  DEFAULT_FOLDER = 'None'

  default_scope { order('pretty_title ASC') }

  belongs_to :space
  belongs_to :user
  belongs_to :folder

  has_many :folders, dependent: :destroy

  alias_method :creator, :user

  validates_presence_of :title,
    message: 'You must provide a title for this folder.'
  validates_uniqueness_of :title, :scope => [ :space_id, :folder_id ],
    message: 'You already have a folder with that title.'

  before_save do
    self.browsable = true if self.browsable.nil?
  end

  before_create do
    # attach to the root folder if no parent was specified
    if self.folder_id.blank? && self.title != DEFAULT_FOLDER
      self.folder_id = self.space.root_folder.id
    end
  end

  validate :title, with: :deny_reserved_titles

  class << self
    def title_available?(title)
      pretty = (title || '').to_s.sanitize
      !pretty.empty? &&
      pretty.length >= 3 &&
      !PageHub::RESERVED_RESOURCE_TITLES.include?(pretty)
    end
  end

  def create_homepage
  end

  def deny_reserved_titles
    if !in_root_folder? && !Folder.title_available?(self.title)
      errors.add :title, "That title is reserved for internal usage."
      return false
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

  def empty?(scope = :public)
    self.folders.empty? && self.pages.all({ browsable: true }).empty?
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

  def ancestors
    parents = []
    p = self
    while p = p.folder do; parents << p end
    parents
  end

  def descendants(with_pages = false)
    folders.collect { |f| f.descendants }.flatten + folders + (with_pages ? pages : [])
  end
end
