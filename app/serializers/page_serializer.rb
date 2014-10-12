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

class PageSerializer < Rack::API::Serializer
  attributes :id, :title, :pretty_title, :browsable, :folder_id, :url, :href,
    :revision_count

  stringify_attributes :folder_id
  user_content_attributes :title, :pretty_title

  def url
    api_v1_folder_page_url(object.folder.space_id, object)
  end

  def href
    generic_resource_url(object.href)
  end

  def revision_count
    object.revisions.count
  end

  def include_revision_count?
    !embedded?
  end
end
