class AddEncryptedToPages < ActiveRecord::Migration
  def change
    change_table :pages do |t|
      t.boolean :encrypted, null: true, default: false
      t.string :digest, null: true
    end
  end
end
