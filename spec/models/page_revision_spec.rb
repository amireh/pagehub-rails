require 'spec_helper'

describe PageRevision do
  before(:all) do
    Fixtures.teardown

    @user = valid! fixture(:user)
    @space = @user.create_default_space
    @root_folder = @space.create_root_folder

    Fixtures.skip_teardown = true
  end

  after(:all) do
    @user.destroy!
    Fixtures.skip_teardown = false
  end

  context "generation" do
    before do
      @user.pages.destroy
      @page = fixture(:page, @root_folder)
    end

    it "should reject generating without a valid context" do
      expect {
        rv = PageRevision.new
        rv.page = @page
        rv.user = @page.user
        rv.save
      }.to raise_error(PageRevision::InvalidContextError, /context must be populated/)
    end

    it "should reject generating without a carbon copy" do
      expect {
        @page.carbon_copy.destroy.should be_true
        @page.reload
        rv = PageRevision.new
        rv.page = @page
        rv.user = @page.user
        rv.context = { content: 'foobar' }
        rv.save
      }.to raise_error(PageRevision::InvalidContextError, /must have a CarbonCopy/)
    end

    it "should generate" do
      rv_count = @page.revisions.count
      @page.generate_revision('foobar', @page.user).should be_true
      @page.reload.revisions.count.should == rv_count + 1
    end

    it "should not generate if content hasn't changed" do
      expect {
        @page.generate_revision(@page.content, @page.user)
      }.to raise_error(PageRevision::NothingChangedError)
    end

    it "should reject patching content too big" do
      really_large_string = 'a' * PageRevision::MAX_PATCH_SIZE

      @page.generate_revision("First revision.", @page.user)

      expect {
        @page.generate_revision(really_large_string, @page.user)
      }.to raise_error(PageRevision::PatchTooBigError)
    end
  end

  describe "instance methods" do
    before(:all) do
      @page = fixture(:page, @root_folder)
      @page.generate_revision('foobar', @page.user).should be_true
      @page.generate_revision('barfoo', @page.user).should be_true

      @page.revisions.count.should == 2

      @rv1 = @page.revisions.first
      @rv2 = @page.revisions.last
    end

    after(:all) do
      @user.pages.destroy
    end

    it "#info" do
      @rv1.info.should == "1 addition and 0 deletions."
      @rv2.info.should == "1 addition and 1 deletion."
    end

    it "#next" do
      @rv1.next.should == @rv2
      @rv2.next.should == nil
    end

    it "#prev" do
      @rv2.prev.should == @rv1
      @rv1.prev.should == nil
    end

    it '#roll' do
      @rv1.send(:roll, :backward, 'foobar').should == ''
      @rv2.send(:roll, :backward, 'barfoo').should == 'foobar'

      @rv1.send(:roll, :forward, '').should == 'foobar'
      @rv2.send(:roll, :forward, 'foobar').should == 'barfoo'
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