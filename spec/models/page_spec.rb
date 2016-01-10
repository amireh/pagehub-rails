require 'rails_helper'

describe Page do
  let!(:user) { a_user }
  let!(:space) { a_space(user) }
  let!(:root_folder) { space.create_root_folder }

  after do
    expect(user.pages.destroy_all).to be_truthy
  end

  it "should be creatable" do
    folder = a_folder(space)
    page = a_page(folder, { title: "Test", user: user })

    expect(page.valid?).to be_truthy
    expect(page.folder).to eq folder

    expect(folder.pages.count).to eq 1
  end

  it "should be destroyed" do
    page = a_page(root_folder)
    expect(page.destroy).to be_truthy
    expect { page.reload }.to raise_error(/Couldn't find Page/)
  end

  it "should generate a carbon copy on creation" do
    page = a_page(root_folder)
    expect(page.carbon_copy).to be_present
    expect(page.carbon_copy.content).to be_blank, 'Initial CC has no content'
  end

  context "versioning" do
    let!(:page) { a_page(root_folder) }

    before do
      @updates = [ "foobar", "adooken", "got\n\nya" ]
      @revisions = []

      @updates.each do |new_content|
        expect(page.generate_revision(new_content, page.user)).to be_truthy
        page.update!({ content: new_content })
      end

      @revisions = page.revisions.to_a

      expect(@revisions.count).to eq @updates.length
      expect(page.content).to eq @updates.last
    end

    it 'snapshotting' do
      expect(page.snapshot(@revisions[0])).to eq 'foobar'
      expect(page.snapshot(@revisions[1])).to eq 'adooken'
      expect(page.snapshot(@revisions[2])).to eq "got\n\nya"
    end

    it 'rolling back' do
      expect(page.content).to eq @updates.last

      expect(page.revisions.count).to eq 3
      page.rollback(@revisions[0])
      page.reload
      expect(page.content).to eq 'foobar'
      expect(page.revisions.count).to eq 1
    end

    it 'rolling back to the latest HEAD' do
      page.rollback(@revisions.last)
      expect(page.reload.content).to eq "got\n\nya"
    end

    it 'rolling back sequentially' do
      @revisions.reverse.each_with_index do |rv, i|
        page.rollback(rv)

        expect(page.content).to eq @updates.reverse[i]
      end
    end
  end
end