class RemoveMemberResources < ActiveRecord::Migration
  def up
    drop_table :member_resources
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
