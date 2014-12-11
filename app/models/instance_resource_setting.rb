class InstanceResourceSetting < ActiveRecord::Base
  unloadable
  belongs_to :setting_object, :polymorphic => true

  PROJECT_RESOURCES_WORKFLOW_KEY = 'ProjectResourcesWorkflow'
  VIEW_RESOURCES = 1
  EDIT_RESOURCES = 2
  scope :visible, ->(project) { where(setting: VIEW_RESOURCES) }
  scope :editable, ->(project) { where(setting: EDIT_RESOURCES) }
  attr_accessible :setting

  def setting_key
    if setting == 2
      :editable
    else
      :visible
    end
  end

end
