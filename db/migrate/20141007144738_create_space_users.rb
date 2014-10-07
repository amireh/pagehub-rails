class CreateSpaceUsers < ActiveRecord::Migration
  def change
    create_table :space_users, id: false do |t|
      t.integer :role, default: 1

      t.references :user
      t.index :user_id
      t.foreign_key :users

      t.references :space
      t.index :space_id
      t.foreign_key :spaces

      t.index [ :user_id, :space_id ], unique: true
      t.index [ :space_id, :role ]

      t.timestamps
    end
  end
end
