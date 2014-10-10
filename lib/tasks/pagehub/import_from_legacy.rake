require 'fileutils'

namespace :pagehub do
  desc 'Import data from the legacy PageHub 1.0 MySQL schema JSON dump.'
  task :import_from_legacy, [:path, :blacklist_path] => :environment do |task, args|
    @failures = []

    @blacklist = begin
      JSON.parse(File.read(args[:blacklist_path]))
    rescue
      {}
    end

    def logger
      Rails.logger || Rack::Logger.new(STDOUT)
    end

    def blacklisted?(resource_type, id)
      return (@blacklist[resource_type.to_s] || []).include?(id)
    end

    def guard(data, &block)
      begin
        block.call
      rescue ActiveRecord::RecordNotFound => e
        logger.error "Failed to import: #{data}"
        logger.error "Cause: #{e.message}"
        @failures << { data: data, error: e.message }
      rescue Exception => e
        @failures << { data: data, error: e.message }
        raise e unless ENV['DESPERATE']
      end
    end

    # User data:
    #
    #   * id
    #   * email
    #   * name
    #   * nickname
    #   * password
    #   * created_at
    #   * preferences
    #   * provider
    #   * uid
    #   * email_verified
    #   * auto_password
    #   * gravatar_email
    def import_user(data)
      logger.debug "\tUser#{data['id']}: #{data['email']} (#{data['provider']})"

      user = User.new
      user.id = data['id']
      user.name = data['name']
      user.nickname = data['nickname']
      user.email = data['email']
      user.created_at = data['created_at']
      user.password = 'temporary'
      user.password_confirmation = 'temporary'
      user.preferences = data['preferences']

      user.save!
      user.update_columns(encrypted_password: data['password'])

      logger.debug "\tUser #{user.id} imported successfully."
    end

    def import_space(data)
      user_id = data['creator_id']
      logger.debug "\tSpace#{data['id']}: #{data['pretty_title']} (#{user_id})"

      user = User.find(user_id.to_s)
      space = Space.new
      space.id = data['id']
      space.title = data['title']
      space.pretty_title = data['pretty_title']
      space.brief = data['brief']
      space.is_public = data['is_public']
      space.created_at = Time.parse(data['created_at'])
      space.preferences = data['preferences']

      space.user = user
      space.save!

      logger.debug "\tSpace #{space.id} imported successfully."
    end

    def import_space_user(data)
      logger.debug "\tSpaceUser: #{data['user_id']} <-> #{data['space_id']} (#{data['role']})"

      user = User.find(data['user_id'].to_s)
      space = Space.find(data['space_id'].to_s)

      SpaceUser.create!({
        user: user,
        space: space,
        role: [ 0, data['role'].to_i - 1 ].max
      })

      logger.debug "\tSpaceUser imported successfully."
    end

    unless args[:path]
      logger.error 'Must provide a path to the JSON dump, e.g: ' +
        '`bundle exec rake pagehub:import_from_legacy[path/to/dump.json]`'
      next
    end

    dump = JSON.parse(File.read(args[:path]))

    # Users
    ActiveRecord::Base.transaction do
      dump['users'] ||= []
      dump['users'].each do |user|
        next if blacklisted?(:users, user['id'])

        import_user(user)
      end
    end

    # Spaces
    ActiveRecord::Base.transaction do
      dump['spaces'] ||= []
      dump['spaces'].each do |resource|
        next if blacklisted?(:spaces, resource['id'])

        guard resource do
          import_space(resource)
        end
      end
    end

    # SpaceUsers
    ActiveRecord::Base.transaction do
      dump['space_users'] ||= []
      dump['space_users'].each do |resource|
        next if blacklisted?(:space_users, resource['id'])

        guard resource do
          import_space_user(resource)
        end
      end
    end

    logger.info "Number of failures: #{@failures.length}"
    logger.info "Failures:"
    logger.info @failures.to_json
  end

  task :import_from_legacy_fragments, [:path, :blacklist_path] => [:environment] do |t, args|
    unless args[:path]
      puts 'Must provide a path to the JSON fragment dump directory, e.g: ' +
        '`bundle exec rake pagehub:import_from_legacy_fragments[path/to/dump_fragments/]`'
      next
    end

    cursor = 0
    cursor_path = Rails.root.join('tmp', 'legacy_fragment_importer.txt')

    if File.exists?(cursor_path)
      cursor = File.read(cursor_path).to_i
      puts "Resuming work from earlier import, starting at #{cursor}."
      puts "To re-run from scratch, delete the file at #{cursor_path} and run" +
        " this task again."
    end

    filenames = (Dir.entries(args[:path]) - ['.','..'] ).sort
    filenames.each_with_index do |filename, i|
      next if i < cursor

      filepath = "#{args[:path]}/#{filename}"
      puts "Importing #{filepath}"

      begin
        Rake::Task["pagehub:import_from_legacy"].reenable
        Rake::Task["pagehub:import_from_legacy"].invoke(filepath, args[:blacklist_path])
      rescue Exception => e
        puts "Import failed: #{e.message}"
        raise e unless ENV['FORCE']
      end

      cursor += 1
      File.write(cursor_path, cursor.to_s)
    end

    puts "Importing done. Make sure you adjust the SEQUENCES by running rake db:adjust_sequences"

    FileUtils.rm(cursor_path)
  end
end
