require 'digest/sha1'

# @class PageRevision
#
# This model represents changes that happened between two versions of a Page
# regarding its content.
#
# A Page model would have a linked-list of PageRevision records that can provide
# it with snapshotting support; the page's content could be restored to any
# "version" by incrementally (de)applying the patches contained in the revision
# patches.
#
# The implementation currently used for generating those diffs/patches and
# applying them is Diff::LCS. The patches are stored as binary in the :blob
# column, and are (de)serialized using `Marshal.dump` which may be a security
# issue as it evaluates the content on the way out.
#
# === How it works
#
# The generation of the patch happens in a callback run before the revision is
# saved.
#
# Basically, we use the Page's CarbonCopy#content as the original content
# from which we will calculate the differences, while the *new* content is
# expected to be found in a property called @new_content. You must assign this
# property when you're about to create the revision otherwise an error will be
# raised.
class PageRevision < ActiveRecord::Base
  belongs_to :page
  belongs_to :user

  default_scope { order(created_at: :asc) }

  class NothingChangedError < RuntimeError; end
  class InvalidContextError < RuntimeError; end
  class BadPatchError < RuntimeError; end
  class PatchTooBigError < RuntimeError; end

  MAX_PATCH_SIZE = 1.megabytes

  attr_writer :new_content

  # @attr [Boolean] from_import
  #
  # Set this to true if you want to assign the :blob and other attributes
  # directly (e.g, you got them from a content import) and would like to bypass
  # the patch-generation callback on creation.
  attr_writer :from_import

  belongs_to :page
  belongs_to :user

  before_create :build_and_save_patch, unless: lambda { @from_import }

  def build_and_save_patch
    if !@new_content
      raise InvalidContextError,
        "Revision context must be populated with the current page content."
    end

    if !page.carbon_copy
      raise InvalidContextError,
        "Page must have a CarbonCopy for a revision to be generated."
    end

    patch = build_patch(page.carbon_copy.content, @new_content)

    # has the content changed?
    if patch.empty?
      raise NothingChangedError
    elsif patch.too_big?
      raise PatchTooBigError
    end

    self.blob = patch.serialize
    self.patchsz = self.blob.length
    self.version = patch.checksum
    self.additions = patch.additions
    self.deletions = patch.deletions

    Rails.logger.debug "New version: #{self.version} (blob: #{self.blob[0..255]}"

    true
  end

  def info
    "#{pluralize(self.additions, 'addition')} and #{pluralize(self.deletions, 'deletion')}."
  end

  # Gets the revision right after this one, if any
  def next
    self.page.revisions.where('created_at > ?', self.created_at).first
  end

  def index
    self.page.revisions.where('created_at < ?', self.created_at).count + 1
  end

  # Gets the revision right before this one, if any
  def prev
    self.page.revisions.where('created_at < ?', self.created_at).last
  end

  def apply(string)
    roll(:backward, string)
  end

  def apply!(string)
    string = apply(string)
    string
  end

  def pretty_version
    version[-8..version.length]
  end

  private

  class Patch < Struct.new(:diff, :additions, :deletions)
    def serialize
      @serialized_diff ||= Marshal.dump(self.diff)
    end

    def checksum
      Digest::SHA1.hexdigest(self.serialize)
    end

    def empty?
      self.diff.length == 0
    end

    def too_big?
      serialize.length >= ::PageRevision::MAX_PATCH_SIZE
    end
  end

  # Generate a patch that, when applied, converts @old_content into @new_content
  # and calculate some diff stats like the number of additions/changes/deletions
  # of characters/lines.
  #
  # @param [String] old_content
  # @param [String] new_content
  #
  # @return [Patch]
  def build_patch(old_content, new_content)
    Rails.logger.debug "Generating diff between #{old_content[0..255]} and #{new_content[0..255]}..."

    patch = Patch.new(nil, 0, 0)
    patch.diff = Diff::LCS.diff(old_content.split("\n"), new_content.split("\n"))

    patch.diff.each do |changeset|
      changeset.each do |d|
        d.action == '-' ? patch.deletions += 1 : patch.additions += 1
      end
    end

    patch
  end

  # Rolling forward is currently unused.
  def roll(direction, str)
    diff = nil

    begin
      diff = Marshal.load(self.blob)
    rescue Exception => e
      raise BadPatchError,
            "Unable to load patch: #{e.class}##{e.message}, revision: #{self.inspect}"
    end

    begin
      case direction
      when :forward
        Diff::LCS.patch!(str.split("\n"), diff).join("\n")
      when :backward
        Diff::LCS.unpatch!(str.split("\n"), diff).join("\n")
      else
        raise "#roll can only go :forward or :backword, but was told to roll in #{direction}"
      end
    rescue Exception => e
      raise BadPatchError,
            "Patch might be corrupt: #{e.class}##{e.message}, revision: #{self.inspect}"
    end
  end

  def pluralize(number, word)
    number == 1 ? "#{number} #{word}" : "#{number} #{word}s"
  end
end
