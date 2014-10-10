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
    end
  end

  module InstanceMethods
    def set_pretty_title
      self.pretty_title = self.title.sanitize
    end
  end
end