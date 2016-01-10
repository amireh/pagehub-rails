module Titlable
  extend ActiveSupport::Concern

  included do |base|
    base.send :include, InstanceMethods
    base.base_class.tap do |klass|
      validates_presence_of :title, message: 'A title must be provided.'
      validates_length_of :title, {
        minimum: 3,
        message: 'Title must be at least 3 characters long.'
      }

      before_save :set_pretty_title, :if => :title_changed?
      scope :titled, ->(raw_title) { where(pretty_title: StringUtils.sanitize(raw_title.to_s)) }
    end
  end

  module InstanceMethods
    def set_pretty_title
      self.pretty_title = StringUtils.sanitize(title.to_s)
    end

    def title=(new_title)
      write_attribute(:pretty_title, StringUtils.sanitize(new_title.to_s))
      super
    end
  end
end