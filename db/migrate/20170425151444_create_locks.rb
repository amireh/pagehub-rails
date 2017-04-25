class CreateLocks < ActiveRecord::Migration
  def change
    create_table :locks do |t|
      t.integer  :resource_id, null: false
      t.string   :resource_type, null: false
      t.integer  :holder_id, null: false
      t.integer  :duration, null: false
      t.timestamps

      t.index :holder_id
      t.index [ :updated_at, :duration ]
    end
  end
end
