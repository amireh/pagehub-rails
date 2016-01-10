require 'rails_helper'

describe PathBuilder do
  let(:user) { a_user }
  let(:space) { a_space(user) }
  let(:root_folder) { space.create_root_folder }

  describe "Instance methods" do
    before do
      @root        = root_folder
      @parent      = a_folder(space, { title: "Parent" })
      @child       = a_folder(space, { title: "Child",     folder_id: @parent.id })
      @grandchild  = a_folder(space, { title: "Granchild", folder_id: @child.id  })
      @uncle       = a_folder(space, { title: "Uncle" })
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
