require 'rails_helper'

describe Api::UsersController, type: :controller do
  let(:user) { a_user }

  it 'lets me see my profile' do
    set_json_headers
    set_auth_headers(user.email, 'helloWorld123')

    get 'show', format: :json, user_id: 'self'

    expect(response.status).to eq(200)
    expect(response_json.keys).to include(:users)
    expect(response_json[:users][0][:id]).to eq(user.id.to_s)
  end
end
