module Lux
  class Lock < ActiveRecord::Base
    self.table_name = "locks"

    DEFAULT_DURATION = 5.minutes

    # Retrieve a locking handle to a lockable resource.
    #
    # @param  [ActiveRecord::Base] resource
    #         The lockable resource.
    #
    # @return [Lock?]
    #
    def self.for(resource)
      attributes = {
        resource_id: resource.id,
        resource_type: resource.class.name
      }

      where(attributes).first || Lock.new(attributes)
    end

    scope :expired, ->() {
      where <<-SQL
        EXTRACT(EPOCH FROM age((now() at time zone 'utc'), updated_at)) > duration
      SQL
    }

    # @return [Boolean] Whether the resource is locked by anyone.
    def self.locked?(resource)
      self.for(resource).persisted?
    end

    # Recycle expired locks by releasing them.
    #
    # @return [Number] The number of locks that were released.
    def self.recycle
      scope = expired
      scope.count.tap do
        scope.destroy_all
      end
    end

    # Attempt to acquire the lock for a specific holder.
    #
    # @param [ActiveRecord::Base] holder:
    # @param [Number] duration:
    #
    # @return [Lux::LOCK_OK]
    # @return [Lux::LOCK_NOT_OWNED]
    def acquire!(holder:, duration: DEFAULT_DURATION)
      if !persisted? || expired?
        self.holder_id = Lock.id_of(holder)
        self.duration = duration

        save!

        Lux::LOCK_OK
      elsif held_by?(holder)
        touch

        Lux::LOCK_OK
      else
        Lux::LOCK_NOT_OWNED
      end
    end

    # Extend the duration of a lock acquired by the holder.
    #
    # @param [ActiveRecord::Base] holder:
    # @param [Number] duration:
    #
    # @return [Lux::LOCK_OK]
    # @return [Lux::LOCK_NOT_OWNED]
    def renew!(holder:)
      if held_by?(holder)
        touch

        Lux::LOCK_OK
      else
        Lux::LOCK_NOT_OWNED
      end
    end

    # Release a lock acquired by the holder.
    #
    # @param [ActiveRecord::Base | Number] holder:
    #
    # @return [Lux::LOCK_OK]
    #  When the lock was released successfully.
    #
    # @return [Lux::LOCK_NOT_OWNED]
    #  When either the resource has not been locked in the first place or that
    #  the specified holder is not the current lock holder.
    def release!(holder:)
      if held_by?(holder)
        destroy!

        Lux::LOCK_OK
      else
        Lux::LOCK_NOT_OWNED
      end
    end

    def held_by?(holder)
      self.holder_id == Lock.id_of(holder)
    end

    def expired?
      !updated_at || Time.now.to_i - updated_at.to_i > duration
    end

    private

    def self.id_of(object)
      object.respond_to?(:id) ? object.id : object
    end
  end
end