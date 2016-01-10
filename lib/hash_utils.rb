# PageHub - Open editing platform.
# Copyright (C) 2016 Algol Labs <hi@algollabs.com>
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

module HashUtils
  # Merges self with another, recursively.
  #
  # This code was lovingly stolen from some random gem:
  # http://gemjack.com/gems/tartan-0.1.1/classes/Hash.html
  #
  # Thanks to whoever made it.
  def self.deep_merge(lhs, rhs)
    target = lhs.dup

    rhs.keys.each do |key|
      if rhs[key].is_a? Hash and lhs[key].is_a? Hash
        target[key] = target[key].deep_merge(rhs[key])
        next
      end

      target[key] = rhs[key]
    end

    target
  end
end
