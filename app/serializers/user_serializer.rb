# PageHub - Open editing platform.
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

class UserSerializer < Rack::API::Serializer
  attributes :id, :name, :nickname, :email, :gravatar_email, :url, :href

  has_many :spaces, embed: :objects

  hypermedia only: [], links: {
    spaces: -> {
      api_v1_user_spaces_url(object.id)
    },
    name_availability: -> {
      api_v1_user_nickname_availability_url
    },
    resend_confirmation_instructions: -> {
      api_v1_user_resend_confirmation_instructions_url
    }
  }

  user_content_attributes :name

  def url
    api_v1_user_url(object.id)
  end

  def href
    generic_resource_url(object.href)
  end

  def include_preferences?
    self_access?
  end

  def include_email?
    self_access?
  end

  def include_spaces?
    self_access?
  end

  def spaces
    if compact?
      object.spaces.includes(:user)
    else
      object.spaces.includes(:user, :users, :pages, :folders, :space_users)
    end
  end

  private

  def self_access?
    scope && scope[:current_user] == object
  end
end
