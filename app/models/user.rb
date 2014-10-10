class User < ActiveRecord::Base
  include Preferencable
  include DeviseUserValidatable

  devise :database_authenticatable,
    :registerable,
    :recoverable,
    :rememberable,
    :trackable,
    # :validatable,
    :confirmable,
    :encryptable,
    :omniauthable,
    {
      password_length: 7..128,
      omniauth_providers: [ :github ]
    }

  has_many :owned_spaces, class_name: 'Space', dependent: :destroy
  has_many :space_users, dependent: :destroy
  has_many :spaces, {
    through: :space_users,
    validate: false
  }

  has_many :folders, dependent: :destroy
  has_many :pages, dependent: :destroy

  before_validation do
    self.encrypted_password = generate_random_password if self.provider != 'pagehub'
    self.uid = UUID.generate if self.provider == 'pagehub'
  end

  before_create do
    self.nickname = self.name.to_s.sanitize if self.nickname.blank?
  end

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

  def create_default_space
    default_space || begin
      owned_spaces.create({ title: Space::DEFAULT_TITLE }).tap do |space|
        space.create_root_folder
      end
    end
  end

  def default_space
    owned_spaces.first
  end

  # TODO: use Ability
  def public_spaces(user)
    if !user
      spaces.where({ is_public: true })
    else
      owned_spaces.select { |s| s.member? user }
    end
  end

  private

  def generate_random_password
    SecureRandom.hex
  end
end
