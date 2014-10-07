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
end
