require 'spec_helper'

describe SpaceService do
  describe '#create' do
    let(:user) { valid! fixture(:user) }

    before do
      @svc = subject.create(user, { title: 'Personal' })
      @space = @svc.output
    end

    it 'should work' do
      @svc.should be_valid
    end

    it "should create a default space for a new user" do
      user.owned_spaces.count.should == 1
    end

    it "should implicitly define a :creator membership for the creator" do
      @space.space_users.count.should == 1
      @space.space_users.creators.where(user_id: user.id).count.should == 1
    end

    it "should create a root folder" do
      @space.root_folder.should be_present
    end

    it "should create a homepage for the space by default" do
      @space.root_folder.has_homepage?.should be_true
    end
  end
end