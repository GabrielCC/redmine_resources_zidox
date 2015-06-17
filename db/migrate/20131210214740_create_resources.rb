class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :name, :null => false, :unique => true
      t.string :code, :null => false, :unique => true
      t.references :department

      t.timestamps
    end
    add_index :resources, :division_id
  end
end
