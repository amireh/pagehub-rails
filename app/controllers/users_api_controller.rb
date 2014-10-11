class UsersApiController < ApiController
  before_filter :require_user

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

    api.consume :preferences do |prefs|
      current_user.save_preferences(current_user.preferences.deep_merge(prefs))
    end

    unless current_user.update(api.parameters)
      halt! 422, current_user.errors
    end

    expose current_user
  end

  def resend_confirmation_instructions
    current_user.send_confirmation_instructions
    no_content!
  end
end
