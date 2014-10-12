class Space < ActiveRecord::Base
  include Preferencable
  include Titlable

  DEFAULT_TITLE = 'Personal'

  default_scope { order(pretty_title: :asc) }

  belongs_to :user
  alias_method :creator, :user

  has_many :space_users, dependent: :destroy
  has_many :users, {
    through: :space_users,
    validate: false
  }

  has_many :folders, dependent: :destroy
  has_many :pages, through: :folders

  validates_presence_of :title,
    message: 'You must provide a title for this space.'
  validates_uniqueness_of :title, :scope => [ :user_id ],
    message: 'You already have a space with that title.'

  def href
    "#{self.user.href}/#{self.pretty_title}"
  end

  def root_folder
    if self.folders.loaded?
      self.folders.detect { |folder| folder.folder_id == nil }
    else
      self.folders.where(folder_id: nil).first
    end
  end

  def create_root_folder
    folder = folders.first_or_create({ title: Folder::DEFAULT_FOLDER }) do |folder|
      folder.user_id = self.user_id
    end

    folder.create_homepage
    folder
  end

  # TODO: ...?
  def folder_pages
    { folders: folders.map(&:serialize) }
  end

  def homepage
    root_folder.homepage
  end

  def is_browsable?
    !!self.is_public
  end

  def browsable_by?(user)
    is_browsable? || member?(user)
  end

  def browsable_pages(cnd = {}, order = [])
    pages.where(cnd.merge({ browsable: true })).order(order)
  end

  def browsable_folders(query = {}, order = [])
    folders.where(query.merge({ browsable: true })).order(order)
  end

  def traverse(folder = root_folder, level = 0, &block)
    yield(folder, level)
    folder.folders.each { |subfolder| traverse(subfolder, level + 1, &block) }
  end

  def locate_resource(path)
    path = Array(path).map(&:to_s).map(&:strip).reject(&:empty?)
    folder = root_folder

    if path.empty?
      if root_folder && root_folder.has_homepage?
        return root_folder.homepage
      end
    end

    path[0..-2].each do |pretty_title|
      folder = folder.folders.where({ pretty_title: pretty_title }).first
      return nil if !folder
    end

    resource_title = path.last.to_s.sanitize
    page = folder.pages.where({ pretty_title: resource_title }).first

    if !page
      if subfolder = folder.folders.where({ pretty_title: resource_title }).first
        if subfolder.has_homepage?
          page = subfolder.homepage
        end
      end
    end

    page
  end

  def all_users
    {
      users: space_users.includes(:user).map do |membership|
        {
          id: membership.user.id,
          nickname: membership.user.nickname,
          role: membership.role
        }
      end
    }
  end

  def role_of(user)
    if membership = cached_find_membership(user.id)
      SpaceUser.role_name(membership.role)
    else
      nil
    end
  end

  def add_with_role(user, role)
    self.send("add_#{role.to_s}".to_sym, user)
  end

  def kick(user)
    if membership = space_users.where({ user_id: user.id }).first
      membership.destroy
    end
  end

  # Add some helpers for querying memberships. Each role will be equipped
  # with the following helpers:
  #
  # Example :member role:
  #
  # - #is_member?(user)
  #   For testing whether a membership of that role (or higher) exists for that
  #   user.
  #
  #   Aliases: #has_member? , #member?
  #
  # - #add_member(user)
  #   Create a new membership of the specified role for this user.
  #
  # - #members()
  #   All users subscribed with this role.
  #
  # TODO: please stop aliasing
  SpaceUser::ROLES.each do |role|
    role_weight = SpaceUser.weigh(role)

    # has_member?(user)
    define_method(:"has_#{role}?") do |user|
      membership = cached_find_membership(user.id)

      return false if membership.blank?

      membership.role >= role_weight
    end

    alias_method :"#{role}?",     :"has_#{role}?"
    alias_method :"is_#{role}?",  :"has_#{role}?"

    next if role == :creator

    # add_member(user)
    define_method(:"add_#{role}") do |user|
      membership = space_users.where(user_id: user.id).first_or_create do |membership|
        membership.role = role_weight
      end

      if membership.role != role_weight
        membership.update({ role: role_weight })
      end

      membership
    end

    # members()
    define_method("#{role}s") do
      space_users.where({ role: role_weight }).includes(:user).map(&:user)
    end
  end

  # Members that can write, edit, and remove pages and folders.
  def authors
    space_users.
      where('role > ?', SpaceUser.weight_of(:member)).
      includes(:user).
      map(&:user)
  end

  def has_member_by_nickname?(nickname)
    users.where(nickname: nickname).any?
  end

  def has_page?(page)
    pages.where(id: page.id).any?
  end

  def has_page_by_title?(title)
    pages.where(pretty_title: title).any?
  end

  def is_creator?(user)
    user && creator.id == user.id
  end

  def default?
    creator.default_space == self
  end

  def orphanize
    authors.each do |u|
      next if u.id == creator.id
      next if u.is_on? 'spaces.no_orphanize'

      user_pages = pages.all({ creator: u })

      next if user_pages.empty?

      s = u.owned_spaces.first_or_create({
        title: "Orphaned: #{title}"
      }, {
        brief: brief
      })

      f = s.root_folder

      user_pages.each { |p|
        p.update({ folder: s.root_folder })
      }
    end

    reload
  end

  def cached_find_membership(user_id)
    if space_users.loaded?
      space_users.detect { |m| m.user_id == user_id }
    else
      space_users.where({ user_id: user_id }).first
    end
  end

  def cached_pages_authored_by(user_id)
    if pages.loaded?
      pages.select { |p| p.user_id == user_id }
    else
      pages.where(user_id: user_id)
    end
  end
end
