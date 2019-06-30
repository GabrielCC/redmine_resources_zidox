ActiveSupport::Reloader.to_prepare do
  paths = '/lib/redmine_zidox/{patches/*_patch,hooks/*_hook}.rb'
  Dir.glob(File.dirname(__FILE__) << paths).each do |file|
    require_dependency file
  end
end

Redmine::Plugin.register :redmine_zidox do
  name 'Redmine Resources'
  author 'Zitec'
  description 'Zidox specific integration for Redmine'
  version '1.4.0'
  url 'https://github.com/sdwolf/redmine_zidox'
  author_url 'http://www.zitec.com'

  requires_redmine version_or_higher: '3.1.1'
  project_module :redmine_zidox do
    permission :view_resources_plugin,
      { resources: [:index, :edit, :trackers] }, public: true
  end
  settings partial: 'redmine_zidox/plugin_settings'
end

Rails.application.config.after_initialize do
  dependencies = {
    redmine_new_issue_view: '1.0.1'
  }
  test_dependencies = { redmine_testing_gems: '1.1.1' }
  redmine_zidox = Redmine::Plugin.find :redmine_zidox
  check_dependencies = proc do |plugin, version|
    begin
      redmine_zidox.requires_redmine_plugin plugin, version
    rescue Redmine::PluginNotFound => error
      raise Redmine::PluginNotFound,
        "Redmine Zidox depends on plugin: " \
          "#{ plugin } version: #{ version }"
    end
  end
  dependencies.each &check_dependencies
  test_dependencies.each &check_dependencies if Rails.env.test?
end
