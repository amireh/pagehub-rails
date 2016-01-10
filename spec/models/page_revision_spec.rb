require 'rails_helper'

describe PageRevision do
  let(:user) { a_user }
  let(:space) { a_space(user) }
  let(:root_folder) { space.create_root_folder }

  context "generation" do
    let(:page) { a_page(root_folder) }

    it "should reject generating without a valid context" do
      expect {
        rv = PageRevision.new
        rv.page = page
        rv.user = page.user
        rv.save
      }.to raise_error(PageRevision::InvalidContextError, /context must be populated/)
    end

    it "should reject generating without a carbon copy" do
      expect {
        page.carbon_copy.destroy!
        page.reload

        rv = PageRevision.new
        rv.page = page
        rv.user = page.user
        rv.new_content = 'foobar'
        rv.save

      }.to raise_error(PageRevision::InvalidContextError, /must have a CarbonCopy/)
    end

    it "should generate" do
      rv_count = page.revisions.count

      expect(page.generate_revision('foobar', page.user)).to be_truthy
      expect(page.reload.revisions.count).to eq(rv_count + 1)
    end

    it "should not generate if content hasn't changed" do
      expect {
        page.generate_revision(page.content, page.user)
      }.to raise_error(PageRevision::NothingChangedError)
    end

    it "should reject patching content too big" do
      really_large_string = 'a' * PageRevision::MAX_PATCH_SIZE

      page.generate_revision("First revision.", page.user)

      expect {
        page.generate_revision(really_large_string, page.user)
      }.to raise_error(PageRevision::PatchTooBigError)
    end
  end

  describe "instance methods" do
    let(:page) { a_page(root_folder) }

    before do
      page.generate_revision('foobar', page.user)
      page.generate_revision('barfoo', page.user)
      page.reload

      expect(page.revisions.count).to eq 2

      @rv1 = page.revisions.first
      @rv2 = page.revisions.last

      expect(@rv1.blob).to_not be_nil
      expect(@rv2.blob).to_not be_nil
    end

    # after(:all) do
    #   @user.pages.destroy
    # end

    it "#info" do
      expect(@rv1.info).to eq "1 addition and 0 deletions."
      expect(@rv2.info).to eq "1 addition and 1 deletion."
    end

    it "#next" do
      expect(@rv1.next).to eq @rv2
      expect(@rv2.next).to eq nil
    end

    it "#prev" do
      expect(@rv2.prev).to eq @rv1
      expect(@rv1.prev).to eq nil
    end

    it '#roll' do
      expect(page.revisions.pluck(:blob)).to_not include(nil)

      expect(@rv1.send(:roll, :backward, 'foobar')).to eq ''
      expect(@rv2.send(:roll, :backward, 'barfoo')).to eq 'foobar'

      expect(@rv1.send(:roll, :forward, '')).to eq 'foobar'
      expect(@rv2.send(:roll, :forward, 'foobar')).to eq 'barfoo'
    end

    it '#roll with a bad patch' do
      old_blob = @rv1.blob

      @rv1.update!({ blob: "#{Marshal.dump(['foo'])}#{@rv1.blob}" })

      expect {
        @rv1.send(:roll, :backward, 'foobar')
      }.to raise_error(Exception, /Patch might be corrupt/)

      @rv1.update!({ blob: old_blob })
    end

    it '#roll with a bad serialized patch' do
      old_blob = @rv1.blob

      @rv1.update!({ blob: "teehee#{@rv1.blob}" })

      expect {
        @rv1.send(:roll, :backward, 'foobar')
      }.to raise_error(Exception, /Unable to load/)

      @rv1.update!({ blob: old_blob })
    end
  end
end