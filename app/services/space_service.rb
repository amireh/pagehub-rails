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

class SpaceService < Service
  def create(user, params)
    params.delete(:id)

    space = user.owned_spaces.create(params)

    unless space.valid?
      return reject_with space.errors
    end

    # subscribe the user as the creator
    space.space_users.creators.create({
      user_id: user.id
    })

    space.create_root_folder

    accept_with space
  end

  def update(space, params)
    attrs = params

    if params[:preferences]
      attrs[:preferences] = HashUtils.deep_merge(space.preferences, params[:preferences])
    end

    space.update_attributes(attrs)
  end
end