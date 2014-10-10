require 'digest/sha1'

class PageRevision < ActiveRecord::Base
  belongs_to :page
  belongs_to :user

  default_scope { order(created_at: :asc) }

  alias_method :editor, :user

  class NothingChangedError < RuntimeError; end
  class InvalidContextError < RuntimeError; end
  class BadPatchError < RuntimeError; end
  class PatchTooBigError < RuntimeError; end

  MAX_PATCH_SIZE = 1.megabytes

  attr_writer :context
  attr_readonly :blob, :version

  belongs_to :page
  belongs_to :user

  before_create :generate_patch

  def generate_patch
    if !@context || !@context[:content]
      raise InvalidContextError,
        "Revision context must be populated with the current page content."
    end

    if !page.carbon_copy
      raise InvalidContextError,
        "Page must have a CarbonCopy for a revision to be generated."
    end

    # puts "Generating diff between #{page.carbon_copy.content} and #{@context[:content]}..."
    diff = Diff::LCS.diff(page.carbon_copy.content.split("\n"), @context[:content].split("\n"))

    # has the content changed?
    if diff.length == 0
      raise NothingChangedError
    end
    # puts "#{diff.length} lines have changed"

    # serialize the patch
    serialized_patch = Marshal.dump(diff)

    # make sure we're within the sanity size
    # puts "patch length: #{serialized_patch.length}"
    if serialized_patch.length >= MAX_PATCH_SIZE
      raise PatchTooBigError
    end

    self.patchsz = serialized_patch.length
    self.blob = serialized_patch
    self.version = Digest::SHA1.hexdigest(serialized_patch)

    changes = { :additions => 0, :deletions => 0 }
    diff.each do |changeset|
      changeset.each do |d|
        d.action == '-' ? changes[:deletions] += 1 : changes[:additions] += 1
      end
    end

    self.additions = changes[:additions]
    self.deletions = changes[:deletions]

    # puts "New version: #{self.version}"

    true
  end

  def info
    "#{pluralize(self.additions, 'addition')} and #{pluralize(self.deletions, 'deletion')}."
  end

  # Gets the revision right after this one, if any
  def next
    self.page.revisions.where('created_at > ?', self.created_at).first
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
