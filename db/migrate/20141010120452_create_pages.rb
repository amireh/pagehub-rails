class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :title, null: false
      t.string :pretty_title
      t.text :content
      t.boolean :browsable

      # folder
      t.references :folder
      t.index :folder_id
      t.foreign_key :folders

      # folder creator
      t.references :user, null: false
      t.index :user_id
      t.foreign_key :users

      # for sorting
      t.index :pretty_title

      t.timestamps
    end
  end
end
