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
end
