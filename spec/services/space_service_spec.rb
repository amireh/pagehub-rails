require 'spec_helper'

describe SpaceService do
  describe '#create' do
    let(:user) { valid! fixture(:user) }

    it "should create a default space for a new user" do
      svc = subject.create(user, { title: 'Personal' })
      svc.should be_valid

      user.owned_spaces.count.should == 1
    end

    it "should implicitly define a :creator membership for the creator" do
      svc = subject.create(user, { title: 'Personal' })
      space = svc.output

      space.space_users.count.should == 1
      space.space_users.creators.where(user_id: user.id).count.should == 1
    end
  end
end