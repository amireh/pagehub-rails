require 'rails_helper'

describe SpaceService do
  describe '#create' do
    let(:user) { a_user }

    before do
      @svc = subject.create(user, { title: 'Personal' })
      @space = @svc.output
    end

    it 'should work' do
      expect(@svc).to be_valid
    end

    it "should create a default space for a new user" do
      expect(user.owned_spaces.count).to eq 1
    end

    it "should implicitly define a :creator membership for the creator" do
      expect(@space.space_users.count).to eq 1
      expect(@space.space_users.creators.where(user_id: user.id).count).to eq 1
    end

    it "should create a root folder" do
      expect(@space.root_folder).to be_present
    end

    it "should create a homepage for the space by default" do
      expect(@space.root_folder.has_homepage?).to eq(true)
    end
  end
end