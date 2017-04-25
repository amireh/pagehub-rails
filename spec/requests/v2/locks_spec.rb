require 'rails_helper'

describe "Locks" do
  subject { api_v2_locks_path }

  let(:user) { a_user }
  let(:space) { a_space_with_folder(user: user) }
  let(:resource) { a_page(space.folders.first) }
  let(:another_holder) { a_user(email: 'someone@else.com') }
  let(:another_resource) { a_page(space.folders.first) }

  describe "#create" do
    it 'works' do
      post subject, {
        resource_id: resource.id,
        resource_type: 'Page'
      }, api_request_headers(user)

      expect(response).to be_success
      expect(response.status).to eq 204

      expect(Lux::Lock.for(resource).held_by?(user)).to eq true
    end

    it 'rejects with 422 if the resource can not be found' do
      post subject, {
        resource_id: 123456789,
        resource_type: 'Page'
      }, api_request_headers(user)

      expect(response).not_to be_success
      expect(response.status).to eq 404
    end

    it 'rejects with 422 if resource is not lockable' do
      resource = a_folder(space)

      post subject, { resource_id: resource.id, resource_type: 'Folder' }, api_request_headers(user)

      expect(response).not_to be_success
      expect(response.status).to eq 422
    end

    it 'rejects with 409 if the resource is locked by someone else' do
      Lux::Lock.for(resource).acquire!(holder: another_holder)

      post subject, {
        resource_id: resource.id,
        resource_type: 'Page'
      }, api_request_headers(user)

      expect(response).not_to be_success
      expect(response.status).to eq 409
    end
  end

  describe "#update" do
    it 'extends my lock duration' do
      Timecop.freeze(3.minutes.ago) do
        Lux::Lock.for(resource).acquire!(holder: user)
      end

      expect {
        patch subject, {
          resource_id: resource.id,
          resource_type: 'Page'
        }, api_request_headers(user)
      }.to change {
        Lux::Lock.for(resource).updated_at
      }
    end

    it 'rejects with 409 if the resource is locked by someone else' do
      Lux::Lock.for(resource).acquire!(holder: another_holder)

      patch subject, {
        resource_id: resource.id,
        resource_type: 'Page'
      }, api_request_headers(user)

      expect(response).not_to be_success
      expect(response.status).to eq 409
    end
  end

  describe "#destroy" do
    it 'releases the lock' do
      Lux::Lock.for(resource).acquire!(holder: user)

      expect {
        delete subject, {
          resource_id: resource.id,
          resource_type: 'Page'
        }, api_request_headers(user)
      }.to change {
        Lux::Lock.locked?(resource)
      }.from(true).to(false)

      expect(response).to be_success
      expect(response.status).to eq 204
    end

    it 'rejects with 409 if the resource was locked by someone else' do
      Lux::Lock.for(resource).acquire!(holder: another_holder)

      expect {
        delete subject, {
          resource_id: resource.id,
          resource_type: 'Page'
        }, api_request_headers(user)
      }.not_to change {
        Lux::Lock.locked?(resource)
      }

      expect(response).not_to be_success
      expect(response.status).to eq 409
    end
  end
end
