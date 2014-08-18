class CreateInstanceResourcesWorkflows < ActiveRecord::Migration
  def change
    create_table :instance_resources_workflows do |t|
      t.integer :old_status_id, :null => false
      t.integer :new_status_id, :null => false

    end

    add_index :instance_resources_workflows, :old_status_id
    add_index :instance_resources_workflows, :new_status_id
  end
end
