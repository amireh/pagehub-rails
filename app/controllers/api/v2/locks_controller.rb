class Api::V2::LocksController < ApiController
  before_filter :require_user

  def create
    with_lockable_resource do |resource|
      if params[:prune] == '1'
        Lux::Lock
          .where(resource_type: params[:resource_type])
          .owned_by(current_user)
          .destroy_all
      end

      case Lux::Lock.for(resource).acquire!(holder: current_user)
      when Lux::LOCK_OK
        head 204
      else
        head 409
      end
    end
  end

  def update
    with_lockable_resource do |resource|
      case Lux::Lock.for(resource).renew!(holder: current_user)
      when Lux::LOCK_OK
        head 204
      else
        head 409
      end
    end
  end

  def destroy
    if params[:resource_type] && !params[:resource_id]
      Lux::Lock
        .where(resource_type: params[:resource_type])
        .owned_by(current_user)
        .destroy_all

      return head 204
    end

    with_lockable_resource do |resource|
      case Lux::Lock.for(resource).release!(holder: current_user)
      when Lux::LOCK_OK
        head 204
      else
        head 409
      end
    end
  end

  private

  def with_lockable_resource
    resource = case params[:resource_type]
    when 'Page'
      Page.find(params[:resource_id])
    end

    return head 422 unless resource

    authorize! :lock, resource

    yield resource
  rescue ActiveRecord::RecordNotFound
    head 404
  end
end
