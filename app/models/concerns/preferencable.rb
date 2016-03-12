module Preferencable
  extend ActiveSupport::Concern

  included do |base|
    base.send :include, InstanceMethods

    base.base_class.tap do |klass|
      klass.cattr_accessor :default_preferences, :preferencable_options
      klass.default_preferences ||= {}
      klass.preferencable_options ||= {
        on: 'preferences'
      }
    end
  end

  module InstanceMethods
    def __override_preferences(values)
      @cached_preferences = values
    end

    def preference(path = nil)
      prefs = preferences

      if path && path.is_a?(String)
        path.split('.').each do |key|
          if prefs.is_a?(Hash)
            prefs = prefs[key]
          else
            prefs = nil
            break
          end
        end
      end

      prefs
    end

    def preferences
      @cached_preferences ||= begin
        klass = self.class.base_class

        default_prefs = klass.default_preferences.clone

        model_prefs = read_attribute(klass.preferencable_options[:on]).to_s
        model_prefs = '{}' if model_prefs.empty?
        model_prefs = JSON.parse(model_prefs)

        # @cached_preferences = Hash.new{ |h,k| h[k] = Hash.new(&h.default_proc) }
        @cached_preferences = {}.with_indifferent_access
        @cached_preferences.merge!(HashUtils.deep_merge(default_prefs, model_prefs))
      end
    end

    def save_preferences(prefs = @cached_preferences)
      @cached_preferences = nil
      attr_key = self.class.base_class.preferencable_options[:on]
      self.update_attribute(attr_key, prefs)
    end

    def preferences=(value)
      @cached_preferences = nil
      write_attribute(:preferences, (value || {}).to_json)
    end

    def is_on?(*setting)
      value = preference(*setting)

      if block_given?
        return yield(value)
      end

      case value
      when String
        !value.empty? && !%w(off false).include?(value)
      when Hash
        !value.empty?
      when TrueClass
        true
      when FalseClass
        false
      when NilClass
        false
      else
        !value.nil?
      end
    end
  end
end