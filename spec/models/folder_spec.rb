require 'rails_helper'

describe Folder do
  it { should belong_to :user }

  let(:user) { a_user }
  let(:space) { a_space(user) }

  before(:each) do
    space.create_root_folder
  end

  it "should be created" do
    folder = a_folder(space)
    expect(folder.folder).to eq folder.space.root_folder
  end

  it "should nest folders" do
    parent = a_folder(space, { title: 'Xyz', user_id: user.id })
    subfolder = a_folder(space, { title: 'Xyz', folder_id: parent.id, user_id: user.id })

    expect(parent.folders).to include(subfolder)
    expect(subfolder.folder).to eq parent
  end

  it "should nest folders with the same title in different levels" do
    parent = a_folder(space, { title: "Mock" })
    child = a_folder(space, { title: "Mock", folder: parent })

    expect(parent.valid?).to eq true
    expect(child.valid?).to eq true
  end

  it "should not allow for duplicate-titled folders" do
    folder1 = a_folder(space, {
      title: "Test",
      user_id: user.id
    })

    folder2 = a_folder(space, {
      title: "Test",
      user_id: user.id
    })

    expect(folder1.valid?).to eq true
    expect(folder2.valid?).to eq false
  end

  it "should not allow for duplicate-titled pages" do
    folder = a_folder(space)

    page1 = a_page(folder, { title: 'Xyz' })
    page2 = a_page(folder, { title: 'Xyz' })
    page3 = a_page(folder, { title: 'ABC' })

    expect(page1.valid?).to eq true
    expect(page2.valid?).to eq false
    expect(page2.errors[:title].first).to eq Page::ERR_NAME_UNAVAILABLE
    expect(page3.valid?).to eq true
  end

  describe "Instance methods" do
    before do
      space.create_root_folder

      @root        = space.root_folder
      @parent      = a_folder(space, { title: "Parent" })
      @child       = a_folder(space, { title: "Child",     folder_id: @parent.id })
      @grandchild  = a_folder(space, { title: "Granchild", folder_id: @child.id  })
      @uncle       = a_folder(space, { title: "Uncle" })
    end

    it "siblings()" do
      expect(@root.siblings.count).to eq 0
      expect(@parent.siblings.count).to eq 1

      f3 = a_folder(space)

      expect(@parent.reload.siblings.count).to eq 2
    end

    it "is_child_of?" do
      expect(@grandchild.is_child_of?(@child)).to  eq(true), 'should be a child of its parent'
      expect(@grandchild.is_child_of?(@parent)).to eq(true), 'should be a child of its grandparent'
      expect(@grandchild.is_child_of?(@root)).to   eq(true), 'should always be a child of the root folder'
      expect(@grandchild.is_child_of?(@uncle)).to  eq(false), "should not be a child of its parent's siblings"
    end

    it "descendants" do
      expect(@root.descendants).to eq   [ @grandchild, @child, @parent, @uncle ]
      expect(@uncle.descendants).to eq  [ ]
      expect(@child.descendants).to eq  [ @grandchild ]
    end
  end

  describe 'Placement' do
  end
end
