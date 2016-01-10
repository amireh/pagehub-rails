require 'rails_helper'

describe Space do
  let(:user) { a_user }
  let(:space) { user.create_default_space }

  subject { space }

  it { should belong_to :user }
  it { should have_many(:space_users).dependent(:destroy) }
  it { should have_many(:folders).dependent(:destroy) }

  it 'validate_uniqueness_of :title within :user_id scope' do
    space2 = a_space(user, { title: space.title })

    expect(space2.valid?).to eq(false)
    expect(space2.errors.get(:title).first).to match /already have a space/
  end

  context "Creation" do
    it "should reject duplicate titled spaces per-user scope" do
      space1 = a_space(user, { title: "Moo" })
      expect(space1.valid?).to eq(true)

      space2 = a_space(user, { title: "Moo" })
      expect(space2.valid?).to eq(false)
      expect(space2.errors[:title].first).to eq 'You already have a space with that title.'

      another_user = a_user({
        name: 'Adooken',
        email: 'something@else.com'
      })

      space3 = a_space(another_user, { title: "Moo" })

      expect(space3.valid?).to eq(true)
    end
  end

  it "update its pretty title whenever the title is updated" do
    space.update({ title: "New Title" })
    expect(space.pretty_title).to eq "new-title"
  end

  context "Memberships" do
    it "should add a member" do
      membership = subject.add_member(user)
      subject.reload
      expect(subject.users.count).to eq 1
      expect(user.spaces.count).to eq 1
    end

    it "should uprank a member" do
      subject.add_member(user)
      expect(subject.role_of(user)).to eq 'member'

      subject.add_admin(user)
      expect(subject.role_of(user)).to eq 'admin'
    end

    it "should downrank a member" do
      subject.add_admin(user)
      expect(subject.role_of(user)).to eq 'admin'

      subject.add_member(user)
      expect(subject.role_of(user)).to eq 'member'
    end
  end

  describe '#destroy' do
    it 'should work' do
      space.destroy!
      user.reload
      expect(user.owned_spaces).to be_empty
    end
  end
end