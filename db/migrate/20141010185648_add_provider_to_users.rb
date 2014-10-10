class AddProviderToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :uid, allow_nil: false
      t.string :provider, default: 'pagehub', allow_nil: false
    end

    remove_index :users, :email
    add_index :users, :email
    add_index :users, [ :email, :provider ], unique: true
  end
end
