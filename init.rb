ActionDispatch::Callbacks.to_prepare do
  paths = '/lib/redmine_resources/{patches/*_patch,hooks/*_hook}.rb'
  Dir.glob(File.dirname(__FILE__) + paths).each do |file|
    require_dependency file
  end
end

Redmine::Plugin.register :redmine_resources do
  name 'Redmine Resources'
  author 'Gabriel Croitoru'
  description 'Redmine Resources Zidox'
  version '1.1.0'
  url 'http://gabrielcc.github.io/redmine_resources/'
  author_url 'http://gabrielcc.github.io/'

  project_module :redmine_resources do
    permission :view_resources_plugin,
      { resources: [:index, :edit, :trackers] }, public: true
  end
end
