class Api::SpaceMembershipsController < ApiController
  def index
    space = Space.find(params[:space_id])

    authorize! :read, space

    render 'api/space_users/index', locals: { memberships: space.space_users }
  end

  def create
    params.require(:membership).permit(:role)

    space = Space.find(params[:space_id])
    user = User.find(params[:user_id])
    role = params[:membership][:role].to_sym

    halt! 400, "User is already a member." if space.member?(user)

    authorize! :invite, [ space, user, role ],
      message: "You can not add #{role.to_s.pluralize} to this space."

    space.add_with_role(user, role.to_sym).tap do |membership|
      render 'api/space_users/index', locals: { memberships: [membership] }
    end
  end

  def update
    params.require(:membership).permit(:role)

    space = Space.find(params[:space_id])
    role = params[:membership][:role].to_s.to_sym
    user = space.users.find(params[:user_id])

    halt! 400, "User is not a member of this space." unless space.member?(user)

    if user == space.creator
      halt! 403, "You can not modify the space creator's membership!"
    elsif user == current_user && role.present?
      halt! 403, "You can not modify your own space membership!"
    end

    if SpaceUser.weigh(role) <= SpaceUser.weight_of(space.role_of(user))
      authorize! :demote, [ space, user, role ], message: 'You can not demote that member.'
    else
      authorize! :promote, [ space, user, role ], message: 'You can not promote that member.'
    end

    space.add_with_role(user, role.to_sym).tap do |membership|
      render 'api/space_users/index', locals: { memberships: [membership] }
    end
  end

  def destroy
    space = Space.find(params[:space_id])
    member = space.users.find(params[:user_id])

    authorize! :kick, [ space, member ],
      message: "You can not kick #{space.role_of(member, true)} in this space."

    space.kick(member)

    head 204
  end
end
