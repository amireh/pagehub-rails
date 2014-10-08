class Space < ActiveRecord::Base
  include Preferencable

  belongs_to :user

  has_many :space_users, dependent: :destroy
  has_many :users, {
    through: :space_users,
    validate: false
  }

  after_create :create_creator_membership

  alias_method :creator, :user

  def role_of(user)
    if entry = space_users.where({ user_id: self.user_id }).first
      entry.role.to_s
    else
      nil
    end
  end

  private

  def create_creator_membership
    self.space_users.first_or_create({ user_id: self.user_id })
  end
end
