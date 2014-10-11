# Adapted from:
# https://github.com/plataformatec/devise/blob/master/lib/devise/models/validatable.rb#L29
module DeviseUserValidatable
  extend ActiveSupport::Concern

  VALIDATIONS = [ :validates_presence_of, :validates_uniqueness_of, :validates_format_of,
                  :validates_confirmation_of, :validates_length_of ].freeze

  def self.required_fields(klass)
    []
  end

  def self.included(base)
    base.extend ClassMethods
    assert_validations_api!(base)

    base.class_eval do
      validates_presence_of :email, if: :email_required?,
        message: 'We need your email address.'

      validates_uniqueness_of :email, scope: [ :provider ], allow_blank: true, if: :email_changed?,
        message: 'That email address is not available.'

      validates_format_of :email, with: email_regexp, allow_blank: true, if: :email_changed?,
        message: 'Email address format does not look right.'

      validates_presence_of     :password, if: :password_required?,
        message: 'You must provide a password.'

      validates_confirmation_of :password, if: :password_required?,
        message: 'You must confirm the passowrd.'

      validates_length_of :password, within: password_length, allow_blank: true,
        message: 'A password must be at least 7 characters long.'
    end
  end

  def self.assert_validations_api!(base) #:nodoc:
    unavailable_validations = VALIDATIONS.select { |v| !base.respond_to?(v) }

    unless unavailable_validations.empty?
      raise "Could not use :validatable module since #{base} does not respond " <<
            "to the following methods: #{unavailable_validations.to_sentence}."
    end
  end

  protected

  # Checks whether a password is needed or not. For validations only.
  # Passwords are always required if it's a new record, or if the password
  # or confirmation are being set somewhere.
  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  def email_required?
    true
  end

  module ClassMethods
    Devise::Models.config(self, :email_regexp, :password_length)
  end
end