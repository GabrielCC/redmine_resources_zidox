class AddSettingToInstanceResourceSettings < ActiveRecord::Migration
  def change
    add_column :instance_resource_settings, :setting, :int
  end
end
