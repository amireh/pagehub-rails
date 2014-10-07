class Space < ActiveRecord::Base
  include Preferencable

  belongs_to :user
  has_many :space_users
  has_many :users, through: :space_users
end
