class SpaceUser < ActiveRecord::Base
  self.primary_keys = :space_id, :user_id

  belongs_to :space
  belongs_to :user
end
