# Pibi API - The official JSON API for Pibi, the personal financing software.
# Copyright (C) 2014 Ahmad Amireh <ahmad@algollabs.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class Rack::API::Serializer < ActiveModel::Serializer
  include Hypermedia

  class_attribute :_stringifiable_attributes
  class_attribute :_user_content_attributes

  def initialize(object, options={})
    super.tap do
      if !options.key?(:embedded)
        options[:embedded] = true
        @root_serializer = true
      end
    end
  end

  # @override
  #
  # - attach Hypermedia links to the serializer output
  # - stringify ids
  # - escape user content
  def serializable_hash
    super.tap do |hsh|
      stringify_ids(hsh, self.class._associations)

      if self.class._hypermedia.present?
        assign_hypermedia_urls(hsh)
      end

      if self.class._user_content_attributes.present?
        present_attributes = self.class._user_content_attributes.select do |field|
          hsh.has_key?(field)
        end

        present_attributes.each do |field|
          hsh[field] = ERB::Util.h(hsh[field])
        end
      end
    end
  end

  # Mark certain attributes as optional, which will be omitted if the user is
  # requesting a compact version of the output, e.g by passing ?compact=true
  # as a request parameter.
  def self.optional_attributes(*fields)
    fields.flatten.each do |field|
      method = "include_#{field}?".to_sym

      unless method_defined?(method)
        define_method method do
          !compact?
        end
      end
    end
  end

  # Mark attributes for HTML escaping.
  def self.user_content_attributes(*fields)
    self._user_content_attributes ||= []
    self._user_content_attributes.concat(Array.wrap(fields).map(&:to_sym))
  end

  # Explicitly mark certain attributes to be stringified. These attributes
  # can either be scalars (numbers), or arrays of scalars. Both will be handled.
  def self.stringify_attributes(*fields)
    self._stringifiable_attributes ||= []
    self._stringifiable_attributes.concat(Array.wrap(fields))
  end

  # Tell whether the user is requesting a compact version of the output.
  #
  # You can use this flag inside your attribute serializers.
  def compact?
    scope && scope[:params] && scope[:params][:compact].present?
  end

  def embedded?
    !@root_serializer && @options[:embedded]
  end

  def requesting?(association)
    scope && scope[:includes] && scope[:includes].include?(association.to_sym)
  end

  private

  def can?(*args)
    if scope[:controller]
      scope[:controller].can?(*args)
    else
      super
    end
  end

  def stringify_ids(hsh, associations)
    hsh[:id] = "#{hsh[:id]}" if hsh[:id]

    attrs = []
    attrs << associations.keys.map do |name|
      singular = name.to_s.singularize
      singular == name.to_s ? "#{name}_id" : "#{singular}_ids"
    end

    if self.class._stringifiable_attributes.present?
      attrs << self.class._stringifiable_attributes.to_a
    end

    attrs.flatten.map(&:to_sym).uniq.select { |k| hsh.has_key?(k) }.each do |key|
      hsh[key] = hsh[key].is_a?(Array) ? hsh[key].map(&:to_s) : "#{hsh[key]}"
    end
  end
end