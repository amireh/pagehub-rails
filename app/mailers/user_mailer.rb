class UserMailer < Devise::Mailer
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`

  # Don't send HTML emails, only text
  def devise_mail(record, action, opts={})
    initialize_from_record(record)

    mail(headers_for(action, opts)) do |format|
      format.text
    end
  end
end