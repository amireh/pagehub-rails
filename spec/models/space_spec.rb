require 'spec_helper'

describe Space do
  let(:user) do
    valid! fixture(:user)
  end

  let(:space) do
    user.create_default_space
  end

  subject { space }

  it { should belong_to :user }
  it { should have_many(:space_users).dependent(:destroy) }
  it { should have_many(:folders).dependent(:destroy) }

  it 'validate_uniqueness_of :title within :user_id scope' do
    space2 = invalid! user.owned_spaces.create({ title: space.title })
    space2.errors.get(:title).first.should =~ /already have a space/
  end

  context "Creation" do
    it "should reject duplicate titled spaces per-user scope" do
      space = valid! fixture(:space, user, { title: "Moo" })
      space = invalid! fixture(:space, user, { title: "Moo" })
      space.errors.get(:title).first.should match(/already have a space with that title/)

      another_user = valid! fixture(:user, {
        name: 'Adooken',
        email: 'something@else.com'
      })

      space = valid! another_user.owned_spaces.create({ title: "Moo" })
    end
  end

  it "update its pretty title whenever the title is updated" do
    space.pretty_title.should == space.title.sanitize
    space.update({ title: "New Title" })
    space.pretty_title.should == "New Title".sanitize
  end

  context "Memberships" do
    it "should add a member" do
      membership = subject.add_member(user)
      subject.reload
      subject.users.count.should == 1
      user.spaces.count.should == 1
    end

    it "should uprank a member" do
      subject.add_member(user)
      subject.role_of(user).should == 'member'

      subject.add_admin(user).should be_true
      subject.role_of(user).should == 'admin'
    end

    it "should downrank a member" do
      subject.add_admin(user)
      subject.role_of(user).should == 'admin'

      subject.add_member(user).should be_true
      subject.role_of(user).should == 'member'
    end
  end

  describe '#destroy' do
    it 'should work' do
      space.destroy.should be_true
      user.reload
      user.owned_spaces.should be_empty
    end
  end
end