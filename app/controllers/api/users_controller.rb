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
        id: user.id.to_s,
        nickname: user.nickname,
        gravatar: gravatar_url(user.gravatar_email, :size => 24)
      }
    end

    render({ json: { users: results } })
  end

  def update
    user_attrs = params.require(:user).permit(
      :name,
      :nickname,
      :gravatar_email,
      :email,
      :current_password,
      :password,
      :password_confirmation,
      preferences: [
        { editing: [
          :font_face,
          :font_size,
          :line_height,
          :letter_spacing,
          :autosave,
        ] },

        { workspace: [
          :fluid,
          :scrolling,
          :animable,
          { browser: [
              :type
          ] }
        ] },

        { runtime: [
            :spaces
        ] },
      ]
    )

    unless user_attrs[:preferences].empty?
      preferences = HashUtils.deep_merge(current_user.preferences, user_attrs[:preferences])
      preferences = HashUtils.deep_merge(User.default_preferences.clone, preferences)

      user_attrs[:preferences] = preferences
    end

    if user_attrs[:password]
      halt! 403 unless current_user.valid_password?(user_attrs[:current_password])
      user_attrs.delete(:current_password)
    end

    unless current_user.update(user_attrs)
      halt! 422, current_user.errors
    end

    render '/api/users/index', locals: {
      users: [ @user ]
    }
  end

  def resend_confirmation_instructions
    current_user.send_confirmation_instructions
    head 204
  end
end
