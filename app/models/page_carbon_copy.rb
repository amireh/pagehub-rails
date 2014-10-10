class PageCarbonCopy < ActiveRecord::Base
  belongs_to :page

  before_save do
    self.content ||= ''
  end
end
