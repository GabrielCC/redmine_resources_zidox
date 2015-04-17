class SetAllExistingIssuesToManuallyUpdated < ActiveRecord::Migration
  def up
    Issue.update_all manually_added_resource_estimation: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
