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
    xit "should create a default space for a new user" do
      pending 'move to SpaceService spec'

      @user.owned_spaces.count.should == 1
      @user.spaces.count.should == 1
    end

    it "should implicitly define a :creator membership for the creator" do
      pending 'move to SpaceService spec'

      space.space_users.count.should == 1
      space.space_users.all({ role: :creator, user: @u }).count.should == 1
    end

    it "should create a homepage for the space by default" do
      pending 'port pages'

      space.root_folder.pages.count.should == 1
    end

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
    # it "should not modify memberships with no editor assigned" do
    #   expect { @s.add_member(@u) }.to raise_error(DataMapper::MissingOperatorError)
    # end

    # it "should not modify memberships by a non-admin" do
    #   u2 = create_user({ email: "user2@tester.com" }, false).first

    #   @s.editor = @u
    #   @s.add_member(u2).should be_true

    #   u3 = create_user({ email: "user3@tester.com" }, false).first

    #   @s.editor = u2
    #   @s.add_member(u3).should be_false
    #   @s.report_errors.should match(/not authorized/)
    # end

    # let(:user2) do
    #   valid! fixture(:user, { name: 'Ahmad', email: 'ahmad@something.com' })
    # end

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

  context "Total annihilation" do
    # it "should reject destroying the default space" do
    #   @space.destroy.should be_false
    #   @space.report_errors.should match(/can not remove the default space/)
    # end

    it "should delete itself cleanly" do
      pending 'port folders & pages'

      s = @u.owned_spaces.create({ title: "The Zoo" })
      s.saved?.should be_true

      @u = @u.refresh

      nr_memberships = @u.space_users.count
      nr_spaces      = @u.spaces.count
      nr_ospaces     = @u.owned_spaces.count
      nr_pages       = Page.count
      nr_folders     = Folder.count
      nr_spages      = s.pages.count
      nr_sfolders    = s.folders.count

      nr_spaces.should == nr_ospaces

      User.editor = s.creator

      s.pages.destroy.should be_true
      s.folders.destroy.should be_true
      s.destroy.should be_true

      @u = @u.refresh
      @u.should be_true

      @u.space_users.count.should   == nr_memberships - 1
      @u.spaces.count.should        == nr_spaces - 1
      @u.owned_spaces.count.should  == nr_ospaces - 1
      Page.count.should   == nr_pages - nr_spages
      Folder.count.should == nr_folders - nr_sfolders
    end

    it "should orphanize its folders into a new user space" do
      pending 'port folders & pages'

      @u2 = valid! fixture(:user)

      u1, u2 = @u, @u2

      # create a space owned by u2
      s = u2.owned_spaces.create({ title: "The Zoo 123" })
      s.saved?.should be_true

      # add u1 to the space
      s.add_admin(u1).should be_true

      # create some page in the space as u1
      valid! s.root_folder.pages.create({ title: "Test", creator: u1 })

      nr_pages = s.pages.count

      s.orphanize.destroy.should be_true

      u1, u2 = u1.refresh, u2.refresh

      u1.spaces.count.should == 2
      u2.spaces.count.should == 1

      orphan = u1.spaces.first({ title: "Orphaned: The Zoo 123" })
      orphan.should be_true
      orphan.pages.count.should == 2
      orphan.pages.first.title.should == "README"
      orphan.pages.last.title.should  == "Test"
    end

    it "should respect the user's orphanizing setting" do
      pending 'port folders & pages'
      fixture(:another_user)

      u1, u2 = @u, @u2

      u1.p['spaces']['no_orphanize'] = true
      u1.save_preferences

      u1 = u1.refresh

      # create a space owned by u2
      s = u2.owned_spaces.create({ title: "The Zoo 123" })
      s.saved?.should be_true

      # add u1 to the space
      # s.editor = s.creator
      s.add_admin(u1).should be_true

      u1 = u1.refresh

      s.users.count.should == 2
      u1.spaces.count.should == 2

      # create some page in the space as u1
      valid! u1.pages.create({ title: "Test", folder: s.root_folder })

      s.pages.last.creator.id.should == u1.id
      nr_pages = s.pages.count

      s.orphanize.destroy.should be_true

      u1, u2 = u1.refresh, u2.refresh

      u1.spaces.count.should == 1
      u2.spaces.count.should == 1

      orphan = u1.spaces.first({ title: "Orphaned: The Zoo 123" })
      orphan.should be_false
    end
  end


end