class CreateSpaces < ActiveRecord::Migration
  def change
    create_table :spaces do |t|
      t.string :title, null: false
      t.string :pretty_title
      t.text :brief
      t.boolean :is_public, default: false
      t.text :preferences

      t.references :user
      t.index :user_id
      t.foreign_key :users

      t.timestamps
    end
  end
end
