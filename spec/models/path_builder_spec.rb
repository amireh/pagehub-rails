require 'spec_helper'

describe PathBuilder do
  let(:user) { valid! fixture(:user) }
  let(:space) { valid! user.create_default_space }

  describe "Instance methods" do
    before do
      space.create_root_folder
      @root        = space.root_folder
      @parent      = valid! fixture(:folder, space, { title: "Parent" })
      @child       = valid! fixture(:folder, space, { title: "Child",     folder_id: @parent.id })
      @grandchild  = valid! fixture(:folder, space, { title: "Granchild", folder_id: @child.id  })
      @uncle       = valid! fixture(:folder, space, { title: "Uncle" })
    end

    describe '.folder_ancestors' do
      it 'excludes the root' do
        expect(subject.folder_ancestors(@root)).to eq []
      end

      it 'works' do
        expect(subject.folder_ancestors(@parent)).to      eq [ @parent]
        expect(subject.folder_ancestors(@child)).to       eq [ @parent, @child ]
        expect(subject.folder_ancestors(@grandchild)).to  eq [ @parent, @child, @grandchild ]
      end
    end
  end
end
