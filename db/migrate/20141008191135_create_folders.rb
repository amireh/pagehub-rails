class CreateFolders < ActiveRecord::Migration
  def change
    create_table :folders do |t|
      t.string :title, null: false
      t.string :pretty_title
      t.boolean :browsable

      # space
      t.references :space, null: false
      t.index :space_id
      t.foreign_key :spaces

      # parent folder
      t.references :folder
      t.index :folder_id
      t.foreign_key :folders

      # folder creator
      t.references :user, null: false
      t.index :user_id
      t.foreign_key :users

      t.timestamps
    end
  end
end
