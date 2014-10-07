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
    includes = if params[:include]
      includes = params[:include].split(',').map(&:strip).map(&:to_sym)
    else
      []
    end

    includes = ['*'] if includes == [:all]

    render options.merge({
      json: object
    })
  end

end