require 'rails_helper'

describe Api::PagesController do
  let!(:user) { a_user }
  let!(:space) { a_space_with_editor(user) }
  let!(:folder) { space.create_root_folder }
  let!(:page) { folder.homepage }

  before(:each) do
    login_as(user)
  end

  describe '#index' do
    it 'works' do
      get 'index', format: :json, folder_id: folder.id

      expect(response.status).to eq(200)
      expect(response_json.keys).to include(:pages)
      expect(response_json[:pages][0][:id]).to eq(page.id.to_s)
    end
  end

  describe '#create' do
    it 'works' do
      post 'create', format: :json, folder_id: folder.id, page: {
        title: 'foo'
      }

      expect(response.status).to eq(200)
      expect(response_json.keys).to include(:pages)
      expect(response_json[:pages][0][:title]).to eq('foo')
    end
  end

  describe '#show' do
    it 'works' do
      get 'show', format: :json, folder_id: folder.id, page_id: page.id

      expect(response.status).to eq(200)
      expect(response_json.keys).to include(:pages)
      expect(response_json[:pages][0][:id]).to eq(page.id.to_s)
    end
  end

  describe '#update' do
    it 'works' do
      patch 'update', format: :json, folder_id: folder.id, page_id: page.id,
        page: {
          title: 'asdfasdf'
        }

      expect(response.status).to eq(200)
      expect(response_json.keys).to include(:pages)
      expect(response_json[:pages][0][:title]).to eq('asdfasdf')
    end

    it 'lets me put the page into a new folder'
    it 'generates a new revision when content changes'
  end

  describe '#destroy' do
    it 'works' do
      delete 'destroy', format: :json, folder_id: folder.id, page_id: page.id

      expect(response.status).to eq(204)
    end
  end
end
