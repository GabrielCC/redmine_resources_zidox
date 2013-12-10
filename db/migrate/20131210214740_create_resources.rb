class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :name
      t.string :code
      t.references :department

      t.timestamps
    end
    add_index :resources, :department_id
  end
end
