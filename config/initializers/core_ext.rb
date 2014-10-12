# require 'action_dispatch/request'
require 'active_record/serializer_override'

String.include CoreExt::String
Hash.include CoreExt::Hash
ActiveRecord::Base.include Ext::ActiveRecord::Base
