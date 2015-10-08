ActionDispatch::Callbacks.to_prepare do
  paths = '/lib/redmine_resources/{patches/*_patch,hooks/*_hook}.rb'
  Dir.glob(File.dirname(__FILE__) << paths).each do |file|
    require_dependency file
  end
end

Redmine::Plugin.register :redmine_resources do
  name 'Redmine Resources'
  author 'Zitec'
  description 'Zidox specific integration for Redmine'
  version '1.2.0'
  url 'https://github.com/sdwolf/redmine_resources'
  author_url 'http://www.zitec.com'

  project_module :redmine_resources do
    permission :view_resources_plugin,
      { resources: [:index, :edit, :trackers] }, public: true
  end
  settings partial: 'settings/plugin'
end
