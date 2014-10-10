class CreatePageCarbonCopies < ActiveRecord::Migration
  def change
    create_table :page_carbon_copies do |t|
      t.text :content

      t.references :page
      t.index :page_id, unique: true
      t.foreign_key :pages

      t.timestamps
    end
  end
end
