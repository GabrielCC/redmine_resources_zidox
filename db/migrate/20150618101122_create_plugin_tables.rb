class CreatePluginTables < ActiveRecord::Migration[4.2]
  def change
    create_table :divisions do |t|
      t.string :name, null: false, unique: true
      t.timestamps
    end

    create_table :resources do |t|
      t.string :name, null: false, unique: true
      t.string :code, null: false, unique: true
      t.references :division
      t.timestamps
    end
    add_index :resources, :division_id

    create_table :resource_settings do |t|
      t.references :project
      t.integer :setting
      t.integer :setting_object_id
      t.string :setting_object_type
    end
    add_index :resource_settings, :project_id
    add_index :resource_settings, :setting_object_id

    create_table :issue_resources do |t|
      t.references :issue
      t.references :resource
      t.integer :estimation
    end
    add_index :issue_resources, :issue_id
    add_index :issue_resources, :resource_id

    create_table :project_resources do |t|
      t.references :project
      t.references :resource
    end
    add_index :project_resources, :project_id
    add_index :project_resources, :resource_id

    create_table :project_resource_emails do |t|
      t.references :project
      t.references :resource
      t.string :email
    end
    add_index :project_resource_emails, :project_id
    add_index :project_resource_emails, :resource_id

    add_column :issues, :manually_added_resource_estimation, :boolean,
      default: false
  end
end
