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

class SpaceUserSerializer < Rack::API::Serializer
  attributes :role, :user_id, :space_id,
    :user_nickname,
    :user_gravatar_email,
    :page_count,
    :folder_count

  def role
    SpaceUser.role_name(object.role)
  end

  def page_count
    object.space.pages.select { |r| r.user_id == object.user_id }.size
  end

  def include_page_count?
    object.space.pages.loaded?
  end

  def folder_count
    object.space.folders.select { |r| r.user_id == object.user_id }.size
  end

  def include_folder_count?
    object.space.folders.loaded?
  end

  def user_nickname
    object.user.nickname
  end

  def include_user_nickname?
    object.association(:user).loaded?
  end

  def user_gravatar_email
    object.user.gravatar_email
  end

  def include_user_gravatar_email?
    object.association(:user).loaded?
  end
end
