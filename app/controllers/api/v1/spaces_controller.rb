class Api::V1::SpacesController < ::ApiController
  before_filter :require_user
  before_filter :require_space, only: [ :show, :update ]

  def index
    authorized_action! :read, @user
    params[:compact] = true
    ams_expose_object @user.spaces.includes(:user)
  end

  def show
    authorized_action! :read, @space

    # eager load the assocs .. especially the space_users as that kills!
    space = Space.
      where(id: params[:space_id]).
      includes(:user, :space_users, :pages, :folders).
      first

    ams_expose_object space
  end

  def update
    authorize! :update, @space,
      message: "You need to be an admin of this space to update it."

    ams_expose_object @space
  end

  def update_memberships
    space = current_user.spaces.
      where(id: params[:space_id]).
      includes(:space_users).
      first

    halt! 404 if space.nil?
    authorize! :read, space

    parameter :memberships, type: :array, allow_nil: true

    api.consume :memberships do |memberships|
      handle_membership_updates(space, memberships)
    end

    ams_expose_object space
  end

  private

  def require_space
    @space = current_user.spaces.find(params[:space_id])
  end

  def handle_membership_updates(space, memberships)
    kicks = memberships.select { |membership| membership[:role].nil? }
    kicks.each do |membership|
      member = space.users.find(membership[:user_id])

      authorize! :kick, [ space, member ],
        message: "You can not kick #{space.role_of(member, true)} in this space."

      space.kick(member)
    end

    (memberships - kicks).each do |membership|
      role = membership[:role].to_s.to_sym
      role_weight = SpaceUser.weigh(role)
      user = space.users.find(membership[:user_id])

      if user == space.creator
        halt! 403, "You can not modify the space creator's membership!"
      elsif user == current_user && role.present?
        halt! 403, "You can not modify your own space membership!"
      end

      if space.member?(user)
        if role_weight <= SpaceUser.weight_of(space.role_of(user))
          authorize! :demote, [ space, user, role ],
            message: 'You can not demote that member.'
        else
          authorize! :promote, [ space, user, role ],
            message: 'You can not promote that member.'
        end
      else
        authorize! :invite, [ space, user, role ],
          message: "You can not add #{role.to_s.pluralize} to this space."
      end

      space.add_with_role(user, role.to_sym)
    end
  end
end
