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
    params.require(:user).permit(
      :name,
      :nickname,
      :gravatar_email,
      :email,
      :preferences,
      :password,
      :password_confirmation
    )

    params.fetch(:user, {}).fetch(:preferences, {}).permit!

    if preferences = params[:user][:preferences]
      current_user.save_preferences(HashUtils.deep_merge(current_user.preferences, preferences))
      params[:user].delete(:preferences)
    end

    unless current_user.update(params[:user])
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
