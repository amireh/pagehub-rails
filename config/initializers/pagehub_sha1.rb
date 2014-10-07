require 'digest/sha1'

module Devise
  module Encryptable
    module Encryptors
      class PagehubSha1 < Base
        def self.digest(password, stretches, salt, pepper)
          puts "Salt: #{salt}"
          # str = if salt == 'legacy'
          #   password
          # else
          #   [password, salt].flatten.compact.join
          # end

          str = password

          Digest::SHA1.hexdigest(str)
        end
      end
    end
  end
end