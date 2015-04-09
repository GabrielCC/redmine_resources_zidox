class AddManuallyAddedResourceEstimationToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :manually_added_resource_estimation, :boolean, default: false
  end
end
