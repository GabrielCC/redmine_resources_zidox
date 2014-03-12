class AddSettingToResourceSettings < ActiveRecord::Migration
  def change
    add_column :resource_settings, :setting, :int
  end
end
