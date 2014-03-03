class ResourceSetting < ActiveRecord::Base
  unloadable
  belongs_to :setting_object, :polymorphic => true
  belongs_to :project
end
