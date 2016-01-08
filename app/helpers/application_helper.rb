module ApplicationHelper
  def js_bundle(name)
    content_for(:deferred_js) do
      js = <<-SCRIPT
        require([ "bundles/#{name}" ]);
      SCRIPT

      js.html_safe
    end
  end

  def logged_in?
    user_signed_in?
  end

  def rabl(template, options={})
    render(template.to_s, options.merge(formats: [:json], handlers: [:rabl]))
  end

  def render_json_object(template, options={})
    rabl(template, options).html_safe
  end

  def render_markdown(string)
    PageHub::Markdown.render! string
  end

  def current_nav_section
    content_for?(:nav_section) ? content_for(:nav_section) : ''
  end

  def current_nav_section?(section)
    current_nav_section == section
  end

  def highlight_if(cnd)
    res = cnd
    res = cnd.call if cnd.respond_to?(:call)
    res ? 'selected' : ''
  end

  def nav_highlight(section)
    highlight_if current_nav_section?(section)
  end

  def preference(key, scope = nil)
    scope ||= @space || @user || current_user || DefaultPreferences

    if scope && scope.respond_to?(:p)
      scope.p(key)
    end
  end

  def traverse_space(space, handlers, cnd = {}, coll = nil)
    raise InvalidArgumentError unless handlers[:on_page] && handlers[:on_page].respond_to?(:call)
    raise InvalidArgumentError unless handlers[:on_folder] && handlers[:on_folder].respond_to?(:call)

    dump_pages = nil
    dump_pages = lambda { |coll|
      coll.each { |p| handlers[:on_page].call(p) }
    }

    unless coll
      dump_pages.call(@space.pages.where(cnd.merge({ folder_id: nil })).order(title: :asc).all)
    end

    dump_folder = nil
    dump_folder = lambda { |f|
      handlers[:on_folder].call(f)
      dump_pages.call(f.pages.where(cnd).order(title: :asc))
      f.folders.where(cnd).each { |cf| dump_folder.call(cf) }
      handlers[:on_folder_done].call(f) if handlers[:on_folder_done]
    }

    (coll || get_space_folders(@space, cnd)).each { |f| dump_folder.call(f) }
  end

  def ordinalized_date(date)
    month = date.strftime('%B')
    day   = date.day.ordinalize
    year  = date.year

    "the #{day} of #{month}, #{year}"
  end

  def pretty_time(datetime)
    datetime.strftime("%D")
  end

  private

  def get_space_folders(space, query)
    space.folders.where(query.merge({ folder_id: nil })).order(title: :asc)
  end
end
