require 'spec_helper'

describe Folder do
  it { should belong_to :user }

  describe "Instance methods" do
    let(:user) { valid! fixture(:user) }
    let(:space) { valid! user.create_default_space }

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

    it "ancestors" do
      @root.ancestors.should         == [ ]
      @parent.ancestors.should       == [ @root ]
      @child.ancestors.should        == [ @parent, @root ]
      @grandchild.ancestors.should   == [ @child, @parent, @root ]
    end

    it "descendants" do
      @root.descendants.should  == [ @grandchild, @child, @parent, @uncle ]
      @uncle.descendants.should == [ ]
      @child.descendants.should == [ @grandchild ]
    end
  end

end
