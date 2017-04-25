require 'rails_helper'
require 'lux'

describe Lux::Lock do
  after(:each) do
    Lux::Lock.destroy_all
  end

  let(:holder) { a_user }
  let(:space) { a_space(holder) }
  let(:resource) { a_page(space.folders.first) }
  let(:another_holder) { a_user(email: 'someone@else.com') }
  let(:another_resource) { a_page(space.folders.first) }

  describe '#acquire' do
    it 'lets me acquire a lock' do
      expect(Lux::Lock.for(resource).acquire!(holder: holder)).to eq(Lux::LOCK_OK)
    end

    it 'does not let me acquire a lock owned by someone else' do
      expect(Lux::Lock.for(resource).acquire!(holder: holder)).to eq(Lux::LOCK_OK)
      expect(Lux::Lock.for(resource).acquire!(holder: another_holder)).to eq(Lux::LOCK_NOT_OWNED)
    end

    context 'when i already own the lock' do
      it 'renews it' do
        expect(Lux::Lock.for(resource).acquire!(holder: holder)).to eq(Lux::LOCK_OK)
        updated_at = Lux::Lock.for(resource).updated_at

        expect {
          Lux::Lock.for(resource).acquire!(holder: holder)
        }.to change { Lux::Lock.for(resource).updated_at }
      end
    end
  end

  describe '#release' do
    it 'lets me release a lock' do
      expect(Lux::Lock.for(resource).acquire!(holder: holder)).to eq(Lux::LOCK_OK)
      expect(Lux::Lock.for(resource).release!(holder: holder)).to eq(Lux::LOCK_OK)

      expect(Lux::Lock.locked?(resource)).to eq(false)
    end

    it 'is a no-op if lock is owned by someone else' do
      expect(Lux::Lock.for(resource).acquire!(holder: holder)).to eq(Lux::LOCK_OK)
      expect(Lux::Lock.for(resource).release!(holder: another_holder)).to eq(Lux::LOCK_NOT_OWNED)

      expect(Lux::Lock.for(resource)).not_to eq(nil)
    end

    it 'is a no-op if lock had not been acquired' do
      expect(Lux::Lock.for(resource).release!(holder: another_holder)).to eq(Lux::LOCK_NOT_OWNED)
    end
  end

  describe '.recycle' do
    it 'releases locks that have timed out' do
      Timecop.freeze(5.minutes.ago) do
        Lux::Lock.for(resource).acquire!(holder: holder, duration: 3.minutes)
        Lux::Lock.for(another_resource).acquire!(holder: holder, duration: 10.minutes)
      end

      expect(Lux::Lock.recycle).to eq 1
      expect(Lux::Lock.locked?(another_resource)).to eq(true)
    end
  end
end