class CreateDepartments < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :name, :null => false, :unique => true
      t.timestamps
    end
  end
end
