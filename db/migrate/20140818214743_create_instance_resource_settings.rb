class CreateInstanceResourceSettings < ActiveRecord::Migration
  def change
    create_table :instance_resource_settings do |t|
      t.integer :setting_object_id
      t.string :setting_object_type
    end
    add_index :instance_resource_settings, :setting_object_id

  end
end
