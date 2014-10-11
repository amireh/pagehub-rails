class Users::RegistrationsController < Devise::RegistrationsController
  def create
    service = UserService.new
    svc = service.create(params)

    self.resource = svc.output

    if svc.valid?
      sign_up(resource_name, resource)
      set_flash_message :notice, :signed_up if is_flashing_format?
      respond_with resource, location: after_sign_up_path_for(resource)
    else
      clean_up_passwords resource
      flash[:error] = resource.errors.map { |error| resource.errors.get(error) }
      respond_with resource
    end
  end
end