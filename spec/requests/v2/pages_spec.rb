require 'rails_helper'

describe "V2::Pages" do
  let(:user) { a_user }
  let(:space) { a_space_with_folder(user: user) }
  let(:folder) { a_folder(space) }
  let(:another_user) { a_user(email: 'someone@else.com' )}

  describe '#index' do
    subject { api_v2_pages_path }

    it 'lets me retrieve pages in a space' do
      first_page = a_page(a_folder(space))

      get subject, { space_id: space.id }, api_request_headers(user)

      expect(response).to be_success
      expect(payload[:pages].length).to eq(space.pages.count)
    end

    it 'lets me retrieve pages in a folder' do
      first_page = a_page(folder)
      second_page = a_page(folder)

      get subject, { folder_id: folder.id }, api_request_headers(user)

      expect(response).to be_success
      expect(payload[:pages].length).to eq(2)
    end
  end

  describe "#create" do
    subject { api_v2_pages_path }

    it 'works' do
      post subject, { folder_id: folder.id }, api_request_headers(user)

      expect(response).to be_success
      expect(response.status).to eq 200
    end
  end

  describe "#update" do
    let(:page) { a_page(folder) }

    subject { api_v2_page_path(page) }

    it 'accepts my update' do
      expect {
        patch subject, { page: { content: 'Hey!' } }, api_request_headers(user)
      }.to change {
        page.reload.content
      }.from('').to('Hey!')
    end

    it 'rejects with 409 if the resource is locked by someone else' do
      Lux::Lock.for(page).acquire!(holder: another_user)

      patch subject, {}, api_request_headers(user)

      expect(response).not_to be_success
      expect(response.status).to eq 409
    end
  end

  describe "#destroy" do
    let(:page) { a_page(folder) }

    subject { api_v2_page_path(page) }

    it 'works' do
      expect {
        delete subject, {}, api_request_headers(user)
      }.to change {
        Page.where(id: page.id).count
      }.from(1).to(0)
    end

    it 'rejects with 409 if the resource was locked by someone else' do
      Lux::Lock.for(page).acquire!(holder: another_user)

      expect {
        delete subject, {}, api_request_headers(user)
      }.not_to change {
        Page.where(id: page.id).count
      }

      expect(response).not_to be_success
      expect(response.status).to eq 409
    end
  end
end
