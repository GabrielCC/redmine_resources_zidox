class AddManuallyAddedToIssueResources < ActiveRecord::Migration
  def change
    add_column :issue_resources, :manually_added, :boolean, default: false
  end
end
