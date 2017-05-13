class SpaceUser < ActiveRecord::Base
  self.primary_keys = :space_id, :user_id

  ROLES = [ :member, :editor, :admin, :creator ]

  belongs_to :space
  belongs_to :user

  ROLES.each_with_index do |role, role_weight|
    role_scope = role.to_s.pluralize.to_sym
    scope role_scope, -> { where(role: role_weight) }
  end

  def role_name
    self.class.role_name(role)
  end

  class << self
    def weigh(role)
      role = ROLES.index(role.to_sym)

      if role.nil?
        raise "Invalid membership role #{role}!"
      end

      role
    end

    def role_name(role_weight)
      ROLES[role_weight.to_i].to_s
    end

    alias_method :weight_of, :weigh
  end
end
