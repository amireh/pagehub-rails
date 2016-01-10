class Api::UsersController < ::ApiController
  include Gravatarify::Base

  before_filter :require_user, only: [ :show, :update ]

  def show
    authorized_action! :read, @user

    render '/api/users/index', locals: {
      users: [ @user ]
    }
  end

  def nickname_availability
    nickname = StringUtils.sanitize(params[:name].to_s)

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

  def search
    params.permit(:nickname)

    halt! 200, [].to_json if params[:nickname].empty?

    results = User.where('nickname LIKE ?', "#{params[:nickname]}%").limit(10).map do |user|
      {
        id: user.id,
        nickname: user.nickname,
        gravatar: gravatar_url(user.gravatar_email, :size => 24)
      }
    end

    render({ json: { users: results } })
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
