namespace :redmine_resources do
  desc 'Moves settings from ResourceSetting to Setting'
  task move_settings: :environment do
    defaults = Setting.plugin_redmine_resources
    if !defaults || defaults.blank?
      puts 'Please configure the plugin from the admin settings'
      return
    end
    resource_id = defaults['resource_id']
    ResourceSetting.where(setting_object_type: 'Role').find_each do |setting|
      project = Project.where(id: setting.project_id).first or next
      settings = Setting.initialize_project_settings project
      settings['resource_id'] = resource_id
      setting_name = setting.setting == 1 ? 'visible' : 'editable'
      settings[setting_name][setting.setting_object_id.to_s] = '1'
      setting_assign = "plugin_redmine_resources_project_#{ project.id }="
      Setting.send setting_assign, settings
    end
  end

  desc 'Populate initial estimation for all issues'
  task populate_estimation: :environment do
    defaults = Setting.plugin_redmine_resources
    if !defaults || defaults.blank?
      puts 'Please configure the plugin from the admin settings'
      return
    end
    custom_field_id = defaults['custom_field_id'].to_i
    Issue.find_each do |issue|
      estimation = issue.issue_resources.sum(:estimation)
      if estimation > 0
        custom_value = CustomValue.where(customized_id: issue.id,
            customized_type: 'Issue', custom_field_id: custom_field_id)
          .first_or_initialize
        custom_value.value = estimation.to_s
        custom_value.save!
      end
    end
  end
end
