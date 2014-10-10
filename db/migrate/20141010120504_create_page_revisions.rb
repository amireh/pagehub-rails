class CreatePageRevisions < ActiveRecord::Migration
  def change
    create_table :page_revisions do |t|
      t.binary :blob, limit: 10.megabytes
      t.string :version

      t.integer :additions, limit: 8
      t.integer :deletions, limit: 8
      t.integer :patchsz, limit: 8

      t.references :page
      t.index :page_id
      t.foreign_key :pages

      t.references :user
      t.index :user_id
      t.foreign_key :users

      # for sorting
      t.index :created_at

      t.timestamps
    end
  end
end
