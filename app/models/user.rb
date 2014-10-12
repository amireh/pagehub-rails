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
      password_length: 6..128,
      # omniauth_providers: [ :github ]
    }

  class << self
    def find_for_github_oauth(hash, current_user)
      User.where(provider: 'github', uid: hash.uid, email: hash.info[:email]).first
    end
  end

  attr_reader :ability

  def can?(*args)
    @ability ||= Ability.new(self)
    @ability.can?(*args)
  end

  has_many :owned_spaces, class_name: 'Space', dependent: :destroy
  has_many :space_users, dependent: :destroy
  has_many :spaces, {
    through: :space_users,
    validate: false
  }

  has_many :folders, dependent: :destroy
  has_many :pages, dependent: :destroy

  validates_presence_of :name, message: 'We need your name.'
  validates_uniqueness_of :nickname, message: 'That nickname is not available.'
  validates_length_of :nickname, within: 3..64,
    message: 'A nickname must be at least three characters long.'

  validate :ensure_has_valid_nickname, if: :nickname_changed?

  before_validation do
    self.encrypted_password = generate_random_password if self.provider != 'pagehub'
    self.uid = UUID.generate if self.provider == 'pagehub'
  end

  def href
    "#{self.nickname}"
  end

  def url(*args)
    user_url(self)
  end

  def gravatar_email
    read_attribute(:gravatar_email) || self.email
  end

  def first_name
    self.name.split(/\s/).first
  end

  # def to_param
  #   nickname
  # end

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

  def ensure_has_valid_nickname
    if nickname.sanitize != nickname
      errors.add :nickname, "Nicknames can only contain letters, numbers, dashes, and underscores."
      return false
    end
  end
end
