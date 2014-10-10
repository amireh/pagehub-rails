require 'spec_helper'

describe Page do
  let :user do
    valid! fixture(:user)
  end

  let :space do
    user.create_default_space.tap do |space|
      space.create_root_folder
    end
  end

  let :root_folder do
    space.root_folder
  end

  after do
    user.pages.destroy_all.should be_true
  end

  it "should be creatable" do
    folder = valid! fixture(:folder, space)
    page = valid! folder.pages.create({ title: "Test", user: user })
    page.folder.should == folder
    folder.pages.count.should == 1
  end

  it "should be destroyed" do
    page = valid! fixture(:page, root_folder)
    page.destroy.should be_true
  end

  it "should generate a carbon copy on creation" do
    page = valid! fixture(:page, root_folder)
    page.carbon_copy.should be_present
    page.carbon_copy.content.should be_blank, 'Initial CC has no content'
  end

  context "versioning" do
    let(:page) { valid! fixture(:page, root_folder) }

    before do
      @updates = [ "foobar", "adooken", "got\n\nya" ]
      @revisions = []

      @updates.each do |new_content|
        page.generate_revision(new_content, page.user).should be_true
        page.update!({ content: new_content })
      end

      @revisions = page.revisions.to_a
      @revisions.count.should == @updates.length

      page.content.should == @updates.last
    end

    it 'snapshotting' do
      page.snapshot(@revisions[0]).should == 'foobar'
      page.snapshot(@revisions[1]).should == 'adooken'
      page.snapshot(@revisions[2]).should == "got\n\nya"
    end

    it 'rolling back' do
      page.content.should == @updates.last
      page.revisions.count.should == 3
      page.rollback(@revisions[0]).should be_true
      page.reload
      page.content.should == 'foobar'
      page.revisions.count.should == 1
    end

    it 'rolling back to the latest HEAD' do
      page.rollback(@revisions.last).should be_true
      page.reload.content.should == "got\n\nya"
    end

    it 'rolling back sequentially' do
      @revisions.reverse.each_with_index do |rv, i|
        page.rollback(rv).should be_true
        page.content.should == @updates.reverse[i]
      end
    end
  end
end