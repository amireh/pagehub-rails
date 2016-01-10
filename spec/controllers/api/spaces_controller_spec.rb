require 'rails_helper'

describe Api::SpacesController do
  let!(:user) { a_user }
  let!(:space) { a_space_with_editor(user) }

  before(:each) do
    login_as(user)
  end

  describe '#index' do
    it 'works' do
      get 'index', format: :json, user_id: user.id

      expect(response.status).to eq(200)
      expect(response_json.keys).to include(:spaces)
      expect(response_json[:spaces][0][:id]).to eq(space.id.to_s)
    end
  end

  describe '#create' do
    it 'works' do
      post 'create', format: :json, user_id: user.id, space: {
        title: 'teehee'
      }

      expect(response.status).to eq(200)
      expect(response_json.keys).to include(:spaces)
      expect(response_json[:spaces][0][:title]).to eq('teehee')
    end

    it 'bails if no title is passed' do
      post 'create', format: :json, user_id: user.id, space: {
        brief: 'asdf'
      }

      expect(response.status).to eq(422)
      expect(response_json[:messages][0]).to eq "Missing required parameter 'title'"
    end
  end

  describe '#show' do
    it 'works' do
      get 'show', format: :json, user_id: user.id, space_id: space.id

      expect(response.status).to eq(200)
      expect(response_json.keys).to include(:spaces)
      expect(response_json[:spaces][0][:id]).to eq(space.id.to_s)
    end
  end

end
