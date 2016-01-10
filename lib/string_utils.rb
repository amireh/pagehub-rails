require 'addressable/uri'

module StringUtils
  def self.sanitize(string)
    Addressable::URI.
      parse(string.downcase.gsub(/[[:^word:]]/u,'-').
      squeeze('-').
      chomp('-')).
      normalized_path
  end
end