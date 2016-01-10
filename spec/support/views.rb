module Support
  module Views
    def render_jbuilder_template(locals = {})
      content = render(template: subject, locals: locals)
      JSON.parse(content, symbolize_names: true)
    end
  end
end
