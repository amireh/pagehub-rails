# require 'action_dispatch/request'

String.include CoreExt::String
Hash.include CoreExt::Hash
ActiveRecord::Base.include Ext::ActiveRecord::Base
