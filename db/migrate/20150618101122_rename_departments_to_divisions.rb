class RenameDepartmentsToDivisions < ActiveRecord::Migration
  def change
    rename_table :departments, :divisions
    remove_index :resources, :department_id
    rename_column :resources, :department_id, :division_id
    add_index :resources, :division_id
  end
end
