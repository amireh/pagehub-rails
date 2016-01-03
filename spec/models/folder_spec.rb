require 'spec_helper'

describe Folder do
  it { should belong_to :user }

  let(:user) { valid! fixture(:user) }
  let(:space) { valid! user.create_default_space }

  it "should be created" do
    f = valid! fixture(:folder, space)
    f.folder.should == f.space.root_folder
  end

  it "should nest folders" do
    parent = valid! space.folders.create!({ title: 'Xyz', user_id: user.id })
    subfolder = valid! space.folders.create!({ title: 'Xyz', folder_id: parent.id, user_id: user.id })

    parent.folders.should include(subfolder)
    subfolder.folder.should == parent
  end

  it "should nest folders with the same title in different levels" do
    f = valid! fixture(:folder, space, { title: "Mock" })
        valid! fixture(:folder, space, { title: "Mock", folder: f })
  end

  it "should not allow for duplicate-titled folders" do
    valid! space.folders.create({
      title: "Test",
      user_id: user.id
    })

    invalid! space.folders.create({
      title: "Test",
      user_id: user.id
    })
  end

  it "should not allow for duplicate-titled pages" do
    folder = fixture(:folder, space)

    page1 = valid!   fixture(:page, folder, { title: 'Xyz' })
    page2 = invalid! fixture(:page, folder, { title: 'Xyz' })
    page3 = valid!   fixture(:page, folder, { title: 'ABC' })
    page2.errors.get(:title).first.should == Page::ERR_NAME_UNAVAILABLE
  end

  describe "Instance methods" do
    before do
      space.create_root_folder
      @root        = space.root_folder
      @parent      = valid! fixture(:folder, space, { title: "Parent" })
      @child       = valid! fixture(:folder, space, { title: "Child",     folder_id: @parent.id })
      @grandchild  = valid! fixture(:folder, space, { title: "Granchild", folder_id: @child.id  })
      @uncle       = valid! fixture(:folder, space, { title: "Uncle" })
    end

    it "siblings()" do
      @root.siblings.count.should == 0
      @parent.siblings.count.should == 1
      f3 = valid! fixture(:folder, space)
      @parent.reload.siblings.count.should == 2
    end

    it "is_child_of?" do
      @grandchild.is_child_of?(@child).should   be_true, 'should be a child of its parent'
      @grandchild.is_child_of?(@parent).should  be_true, 'should be a child of its grandparent'
      @grandchild.is_child_of?(@root).should    be_true, 'should always be a child of the root folder'
      @grandchild.is_child_of?(@uncle).should   be_false, "should not be a child of its parent's siblings"
    end

    it "descendants" do
      @root.descendants.should  == [ @grandchild, @child, @parent, @uncle ]
      @uncle.descendants.should == [ ]
      @child.descendants.should == [ @grandchild ]
    end
  end

  describe 'Placement' do
  end
end
