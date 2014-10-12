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
  attributes :id, :title, :pretty_title, :brief, :is_public, :url

  has_many :folders
  has_many :pages
  has_many :space_users, key: 'memberships'

  hypermedia only: [], links: {
    folders: -> { api_v1_space_folders_url(object) }
  }

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
end
