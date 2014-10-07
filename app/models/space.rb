class Space < ActiveRecord::Base
  include Preferencable

  belongs_to :user

  has_many :space_users, dependent: :destroy
  has_many :users, {
    through: :space_users,
    validate: false
  }

  alias_method :creator, :user
end
