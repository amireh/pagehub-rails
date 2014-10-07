describe 'import_from_legacy rake task' do
  require 'rake'

  let :path do
    Rails.root.join('tmp', 'legacy_import_fixture.json')
  end

  let :blacklist_path do
    Rails.root.join('tmp', 'legacy_import_fixture_blacklist.json')
  end

  let :task do
    Rake::Task["pagehub:import_from_legacy"]
  end

  def run(data = {}, blacklist={})
    h = data.values.each_with_object({}) do |v, h| h.merge!(v) end
    File.write(path, h.to_json)
    File.write(blacklist_path, blacklist.to_json)
    task.reenable
    task.invoke(path, blacklist_path)
  end

  before :all do
    Rake::Task.define_task(:environment)
    Rake.application.rake_require "tasks/pagehub/import_from_legacy"
  end

  after do
    FileUtils.rm(path) if File.exists?(path)
  end

  it 'should import users' do
    run({
      'users' => json_fixture('import_from_legacy/users.json')
    })

    User.count.should == 2
  end

  describe 'spaces' do
    before do
      run({
        'users' => json_fixture('import_from_legacy/users.json'),
        'spaces' => json_fixture('import_from_legacy/spaces.json')
      })
    end

    it 'should import spaces' do
      User.count.should == 2
      Space.count.should == 5

      User.find(1).owned_spaces.count.should == 3
      User.find(2).owned_spaces.count.should == 2
    end

    it 'should import attributes properly' do
      space = Space.find(1)
      space.title.should == 'Personal'
      space.pretty_title.should == 'personal'
      space.is_public.should == false
      space.preferences['publishing'].should be_present
      space.preferences['publishing']['scheme'].should == 'Clean'
      space.created_at.should == Time.parse('2013-02-19T21:59:02+02:00')
    end
  end

  it 'should import space_users' do
    run({
      'users' => json_fixture('import_from_legacy/users.json'),
      'spaces' => json_fixture('import_from_legacy/spaces.json'),
      'space_users' => json_fixture('import_from_legacy/space_users.json')
    })

    SpaceUser.count.should == 1
  end

  it 'should not import blacklisted items' do
    run({
      users: {
        users: [{
          id: 10
        }]
      }
    }, { users: [ 10 ]})

    User.count.should == 0
  end

  it 'should import everything' do
    run({
      'users' => json_fixture('import_from_legacy/users.json')
    })
  end
end