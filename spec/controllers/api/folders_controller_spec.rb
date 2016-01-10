require 'rails_helper'

describe Api::FoldersController do
  let!(:user) { a_user }
  let!(:space) { a_space_with_editor(user) }
  let!(:root_folder) { space.create_root_folder }

  before(:each) do
    login_as(user)
  end

  describe '#index' do
    it 'works' do
      get 'index', format: :json, space_id: space.id

      expect(response.status).to eq(200)
      expect(response_json.keys).to include(:folders)
      expect(response_json[:folders][0][:id]).to eq(root_folder.id.to_s)
    end
  end

  describe '#show' do
    it 'works' do
      get 'show', format: :json, space_id: space.id, folder_id: root_folder.id

      expect(response.status).to eq(200)
      expect(response_json.keys).to include(:folders)
      expect(response_json[:folders].count).to eq(1)
      expect(response_json[:folders][0][:id]).to eq(root_folder.id.to_s)
    end
  end

  describe '#update' do
    let!(:folder) { a_folder(space) }

    it 'works' do
      patch 'update', format: :json,
        space_id: space.id,
        folder_id: folder.id,
        folder: {
          title: 'asdfasdf'
        }

      expect(response.status).to eq(200)
      expect(folder.reload.title).to eq 'asdfasdf'
    end
  end
end
