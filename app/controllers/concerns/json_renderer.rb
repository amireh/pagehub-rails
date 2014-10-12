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

  def ams_expose_object(object, options={})
    includes = []

    if params.has_key?(:include)
      includes = if params[:include].is_a?(String)
        params[:include].split(',')
      else
        Array(params[:include])
      end

      includes = includes.map(&:strip).map(&:to_sym)
      includes = ['*'] if includes == [:all]
    end

    render options.merge({
      json: object,
      root: false,
      includes: true,
      scope: {
        current_user: current_user,
        controller: self,
        includes: includes,
        params: params,
        options: options
      }
    })
  end

  def ams_render_object(object, serializer, options={})
    serializer.new(object, {
      root: false,
      includes: true,
      scope: {
        controller: self,
        current_user: current_user,
        includes: Array(options[:include]),
        options: {}
      }
    }).as_json
  end

  def json_render_set(set, each_serializer, options={})
    ActiveModel::ArraySerializer.new(set, {
      root: false,
      includes: true,
      each_serializer: each_serializer,
      scope: {
        controller: self,
        current_user: current_user,
        includes: Array(options[:include]),
        options: {}
      }
    }).as_json
  end
end