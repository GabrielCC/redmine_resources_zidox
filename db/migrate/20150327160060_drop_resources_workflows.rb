class DropResourcesWorkflows < ActiveRecord::Migration
  def up
    drop_table :resources_workflows
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
