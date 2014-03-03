class CreateResourceSettings < ActiveRecord::Migration
  def change
    create_table :resource_settings do |t|
      t.references :project
      t.integer :setting_object_id
      t.string :setting_object_type
    end

    add_index :resource_settings, :project_id

    add_index :resource_settings, :setting_object_id

  end
end
