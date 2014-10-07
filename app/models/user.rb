class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :encryptable

  def href(*args)
  end

  def url(*args)
    user_url(self)
  end

  def preferences=(value)
    write_attribute(:preferences, (value || {}).to_json)
  end
end
