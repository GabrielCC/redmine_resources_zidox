class ResourceSetting < ActiveRecord::Base
  unloadable
  belongs_to :setting_object, :polymorphic => true
  belongs_to :project

  PROJECT_RESOURCES_WORKFLOW_KEY = 'ProjectResourcesWorkflow'
  PROJECT_RESOURCES_TRACKER_KEY = 'ProjectResourcesTracker'
  VIEW_RESOURCES = 1
  EDIT_RESOURCES = 2
  scope :visible, ->(project) { where(setting: VIEW_RESOURCES).where(project_id: project.id) }
  scope :editable, ->(project) { where(setting: EDIT_RESOURCES).where(project_id: project.id) }
  attr_accessible :setting

  def setting_key
    if setting == 2
      :editable
    else
      :visible
    end
  end

  def self.get_project_specific_workflow(project_id)
    self.where(:project_id => project_id, :setting_object_type => ResourceSetting::PROJECT_RESOURCES_WORKFLOW_KEY).limit(1).pop
  end

  def self.project_workflow_editable(project_id)
    setting = self.get_project_specific_workflow(project_id)
    !setting.nil?
  end

  def self.activate_project_workflow_editable(project_id)
    rs = self.new
    rs.project_id = project_id
    rs.setting_object_type = self::PROJECT_RESOURCES_WORKFLOW_KEY
    rs.setting_object_id = 1
    rs.setting = self::EDIT_RESOURCES
    rs.save
  end


  def self.get_project_specific_tracker(project_id)
    self.where(:project_id => project_id, :setting_object_type => ResourceSetting::PROJECT_RESOURCES_TRACKER_KEY).limit(1).pop
  end

  def self.project_tracker_editable(project_id)
    setting = self.get_project_specific_tracker(project_id)
    !setting.nil?
  end

  def self.activate_project_tracker_editable(project_id)
    rs = self.new
    rs.project_id = project_id
    rs.setting_object_type = self::PROJECT_RESOURCES_TRACKER_KEY
    rs.setting_object_id = 1
    rs.setting = self::EDIT_RESOURCES
    rs.save
  end

end
