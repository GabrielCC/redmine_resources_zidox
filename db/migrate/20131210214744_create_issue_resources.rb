class CreateIssueResources < ActiveRecord::Migration
  def change
    create_table :issue_resources do |t|

      t.references :issue

      t.references :resource

      t.integer :estimation


    end

    add_index :issue_resources, :issue_id

    add_index :issue_resources, :resource_id

  end
end
