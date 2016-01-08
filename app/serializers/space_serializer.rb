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

class SpaceSerializer < Rack::API::Serializer
  attributes :id, :title, :pretty_title, :brief, :is_public, :url, :creator, :preferences

  has_many :folders
  has_many :pages
  has_many :space_users, key: 'memberships'

  hypermedia only: [], links: {
    edit: -> { user_space_edit_url(object.user.nickname, object.pretty_title) },
    folders: -> { api_v1_space_folders_url(object) },
    memberships: -> { api_v1_user_space_memberships_url(object.user_id, object) },
    settings: -> { user_space_settings_url(object.user.nickname, object.pretty_title) },
  }

  user_content_attributes :title, :pretty_title, :brief

  def url
    api_v1_user_space_url(object.user, object)
  end

  def include_pages?
    !compact? && requesting?(:pages)
  end

  def include_folders?
    !compact?
  end

  def include_space_users?
    !compact?
  end

  def creator
    {
      id: object.user.id.to_s,
      nickname: object.user.nickname.to_s
    }
  end
end
