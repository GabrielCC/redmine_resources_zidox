namespace :redmine_resources do
  desc 'Moves settings from ResourceSetting to Setting'
  task move_settings: :environment do
    resource_id = Setting.plugin_redmine_resources['resource_id']
    ResourceSetting.where(setting_object_type: 'Role').find_each do |setting|
      project = Project.where(id: setting.project_id).first or next
      settings = Setting.initialize_project_settings project
      settings['custom'] = '1'
      settings['resource_id'] = resource_id
      setting_name = setting.setting == 1 ? 'visible' : 'editable'
      settings[setting_name][setting.setting_object_id.to_s] = '1'
      setting_assign = "plugin_redmine_resources_project_#{ project.id }="
      Setting.send setting_assign, settings
    end
  end
end
