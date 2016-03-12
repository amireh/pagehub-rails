module HashUtils
  # Performs a deep merge between two hashes, keeping non-nil values in place.
  #
  # Credit goes to:
  # https://bibwild.wordpress.com/2010/08/03/ruby-hashmerge-with-block-who-knew/
  #
  def self.deep_merge(source_hash, new_hash)
    source_hash.merge(new_hash) do |key, old_value, new_value|
      if new_value.nil?
        old_value
      elsif (old_value.kind_of?(Hash) and new_value.kind_of?(Hash))
        deep_merge(old_value, new_value)
      elsif (old_value.kind_of?(Array) and new_value.kind_of?(Array))
        old_value.concat(new_value).uniq
      else
        new_value
     end
   end
  end
end
