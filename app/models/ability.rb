class Ability
  include CanCan::Ability

  def initialize(user)
    return false unless user.present?

    user_id = user.id

    can :browse, [ Space, Page, Folder ] do |r|
      r.browsable_by?(user)
    end

    can :manage, User do |u|
      u.id == user.id
    end

    can :read, [ Space, Page, Folder ] do |r|
      r.browsable_by?(user)
    end

    can :access, Space do |s|
      s.member?(user)
    end

    # space resources
    can :author, Space do |s| s.editor?(user) end
    can :author_more, Space

    can :update, [ Page, Folder ] do |r| r.space.editor?(user) end
    can :delete, [ Page, Folder ] do |r|
      r.creator.id == user.id || r.space.admin?(user)
    end

    # spaces
    can :create, Space
    can :update, Space do |s|
      s.admin?(user)
    end
    can :update_meta, Space do |s| s.creator?(user) end
    can :delete,      Space do |s| s.creator?(user) end

    can :invite, Array do |a|
      space, target, role = *a

      if space.creator?(user)
        true
      else
        space.admin?(user) && space.role_of(target) == nil && role.to_sym != :admin
      end
    end

    can :kick, Array do |a|
      space, victim = *a

      if space.creator?(user)
        true
      elsif victim.id == user.id
        true
      else
        space.admin?(user) && !space.admin?(victim)
      end
    end

    can :promote, Array do |a|
      space, victim, role = *a

      if space.creator?(user)
        true
      else
        space.admin?(user) && space.member?(victim) && [:member, :editor].include?(role.to_sym)
      end
    end

    can :demote, Array do |a|
      space, victim, role = *a

      if space.creator?(user)
        true
      else
        space.admin?(user) && !space.admin?(victim) && [:member, :editor].include?(role.to_sym)
      end
    end
  end
end
