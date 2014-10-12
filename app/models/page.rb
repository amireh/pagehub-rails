class Page < ActiveRecord::Base
  include Titlable
  include FolderContainable

  default_scope { order(pretty_title: :asc) }

  README_PAGE = 'README'

  belongs_to :user
  alias_method :creator, :user

  has_many :revisions, class_name: 'PageRevision', dependent: :destroy
  has_one :carbon_copy, class_name: 'PageCarbonCopy', dependent: :destroy
  has_one :space, through: :folder

  before_validation :generate_default_title
  before_save :set_defaults
  after_create :create_carbon_copy

  scope :browsable, -> { where browsable: true }

  class << self
    def random_suffix
      Base64.urlsafe_encode64(Random.rand(12345 * 100).to_s)
    end
  end

  def href
    "#{folder.href}/#{pretty_title}"
  end

  def in_root_folder?
    self.folder.in_root_folder?
  end

  # ---------------------------------------------------------------------------
  # <Permissions>
  #
  # TODO: move to Ability
  def browsable_by?(user)
    return true if space.member?(user)

    browsable && folder.browsable_by?(user)
  end

  def editable_by?(user)
    folder.space.editor?(user)
  end
  # </Permissions>
  # ---------------------------------------------------------------------------

  def generate_revision(new_content, user)
    if self.id.nil?
      errors.add :revisions, "Page revisions can not be generated from new pages."
      return false
    end

    if !new_content
      return false
    end

    unless rv = revisions.create({ new_content: new_content, user: user })
      errors.add :revisions, rv.errors
      return false
    end

    self.carbon_copy.update!({ content: new_content })

    true
  end

  def snapshot(target_revision, snapshotted = nil)
    snapshotted ||= self.carbon_copy.content.dup

    self.revisions.reorder(created_at: :desc).each do |revision|
      break if revision.id == target_revision.id
      snapshotted = revision.apply(snapshotted)
    end

    snapshotted
  end

  # Replaces the content of the carbon copy and the page with
  # the snapshot taken from the specified revision. All revisions
  # created after the specified one will be destroyed.
  def rollback(target_revision)
    new_content     = snapshot(target_revision)
    current_content = self.content.dup

    unless carbon_copy.update({ content: new_content })
      return false
    end

    unless self.update({ content: new_content })
      carbon_copy.update!({ content: current_content })

      return false
    end

    unless revisions.where('created_at > ?', target_revision.created_at).destroy_all
      self.update!({ content: current_content })
      self.carbon_copy.update!({ content: current_content })

      return false
    end

    true
  end

  def is_homepage?
    self.folder.homepage == self
  end

  def serialize(with_content = false)
    s = {
      id: id,
      title: title,
      folder: folder_id || 0,
      nr_revisions: revisions.count
    }
    s[:content] = content if with_content
    s
  end

  def to_json(*args)
    serialize(args).to_json
  end

  def space
    folder.space
  end

  private

  def set_defaults
    self.browsable = true if self.browsable.nil?
    self.content ||= ''
  end

  def generate_default_title
    if self.title.blank?
      self.title = "Untitled ##{Page.random_suffix}"
      self.pretty_title = self.title.sanitize
    end
  end

  def create_carbon_copy
    # Don't initialize the CC with our content because
    # we want the first revision to reflect the entire
    # changes the post was first created with.
    carbon_copy = self.build_carbon_copy
    carbon_copy.save!
  end
end
