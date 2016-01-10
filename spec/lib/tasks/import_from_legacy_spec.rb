require 'rails_helper'
require 'rake'

describe 'import_from_legacy rake task' do
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

    expect(User.count).to eq 2
  end

  describe 'spaces' do
    before do
      run({
        'users' => json_fixture('import_from_legacy/users.json'),
        'spaces' => json_fixture('import_from_legacy/spaces.json')
      })
    end

    it 'should import spaces' do
      expect(User.count).to eq 2
      expect(Space.count).to eq 5

      expect(User.find(1).owned_spaces.count).to eq 3
      expect(User.find(2).owned_spaces.count).to eq 2
    end

    it 'should import attributes properly' do
      space = Space.find(1)
      expect(space.title).to eq 'Personal'
      expect(space.pretty_title).to eq 'personal'
      expect(space.is_public).to eq false
      expect(space.preferences['publishing']).to be_present
      expect(space.preferences['publishing']['scheme']).to eq 'Clean'
      expect(space.created_at).to eq Time.parse('2013-02-19T21:59:02+02:00')
    end
  end

  it 'should import space_users' do
    run({
      'users' => json_fixture('import_from_legacy/users.json'),
      'spaces' => json_fixture('import_from_legacy/spaces.json'),
      'space_users' => json_fixture('import_from_legacy/space_users.json')
    })

    expect(SpaceUser.count).to eq 1
  end

  it 'should not import blacklisted items' do
    run({
      users: {
        users: [{
          id: 10
        }]
      }
    }, { users: [ 10 ]})

    expect(User.count).to eq 0
  end

  it 'should import everything' do
    run({
      'users' => json_fixture('import_from_legacy/users.json')
    })
  end

  def json_fixture(path)
    json = JSON.parse File.read File.join(Rails.root, 'spec', 'fixtures', path)
    json.is_a?(Hash) ? json.with_indifferent_access : json
  end
end