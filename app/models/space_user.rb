class SpaceUser < ActiveRecord::Base
  belongs_to :space
  belongs_to :user
end
