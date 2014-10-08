class User < ActiveRecord::Base
  include Preferencable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
    :registerable,
    :recoverable,
    :rememberable,
    :trackable,
    :validatable,
    :confirmable,
    :encryptable,
    {
      password_length: 7..128
    }

  has_many :owned_spaces, class_name: 'Space', dependent: :destroy
  has_many :space_users, dependent: :destroy
  has_many :spaces, {
    through: :space_users,
    validate: false
  }

  def href(*args)
  end

  def url(*args)
    user_url(self)
  end

  def gravatar_email
    read_attribute(:gravatar_email) || self.email
  end

  def to_param
    nickname
  end
end
