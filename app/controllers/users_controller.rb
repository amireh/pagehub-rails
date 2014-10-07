class UsersController < ApplicationController
  include Rack::API::Parameters

  respond_to :html, :json

  before_filter :require_user
  before_filter :require_json_format, only: [ :update, :show ]

  def dashboard
    @user = current_user
  end

  def show
    expose current_user
  end

  def nickname_availability
    nickname = (params[:name] || '').to_s.sanitize

    available = nickname.present? &&
      nickname.length >= 3 &&
      !PageHub::RESERVED_USERNAMES.include?(nickname) &&
      User.find_by({ nickname: nickname }).nil?

    render({
      json: {
        available: available
      }
    })
  end

  def update
    accepts *[
      :name,
      :nickname,
      :gravatar_email,
      :email,
      :preferences,
      :password,
      :password_confirmation
    ]

    # parameter :current_password, validator: lambda { |value|
    #   value ||= ''

    #   if !value.empty? && User.encrypt(value) != current_user.password
    #     return "The current password you entered is wrong."
    #   end
    # }

    api.consume :preferences do |prefs|
      current_user.save_preferences(current_user.preferences.deep_merge(prefs))
    end

    # api.consume :current_password

    current_user.update(api.parameters)

    expose current_user
  end
end
