class CreateResourcesWorkflows < ActiveRecord::Migration
  def change
    create_table :resources_workflows do |t|
      t.references :project
      t.integer :old_status_id, :null => false
      t.integer :new_status_id, :null => false

    end

    add_index :resources_workflows, :project_id
    add_index :resources_workflows, :old_status_id
    add_index :resources_workflows, :new_status_id
  end
end
