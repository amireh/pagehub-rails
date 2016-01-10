module JsonRenderer
  def expose(object, options={})
    object.respond_to?(:to_ary) ?
      expose_collection(object, options) :
      expose_object(object, options)
  end

  def expose_collection(collection, options={})
    paginated_set = if options[:paginate] != false
      api_paginate(collection)
    else
      collection
    end

    expose_object(paginated_set, options)
  end

  def expose_object(object, options={})
    ams_expose_object(object, options)
  end

end