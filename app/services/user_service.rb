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

class UserService < Service
  CREATION_ATTRS = %w[
    name
    nickname
    uid
    provider
    email
    password
    password_confirmation
  ].map(&:to_sym).freeze

  def create(params)
    svc = Result.new

    attrs = ActionController::Parameters.new(params.slice(*CREATION_ATTRS))
    attrs[:provider] ||= 'pagehub'
    attrs[:uid] ||= UUID.generate()
    attrs[:nickname] ||= StringUtils.sanitize(params[:name].to_s)
    attrs.permit!

    svc.output = user = User.create(attrs)

    unless user.valid?
      return svc.reject(user.errors)
    end

    user.create_default_space

    svc.accept(user)
  end
end