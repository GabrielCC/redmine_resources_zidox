require "redmine"

# Patches to the Redmine core.
ActionDispatch::Callbacks.to_prepare do
  require_dependency 'member'
  require_dependency 'project'
  require_dependency 'role'
  require_dependency 'tracker'
  require_dependency 'members_controller'
  require_dependency 'issue'
  require_dependency 'application_helper'
  require_dependency 'issues_helper'
  require_dependency 'hook_listener'

  Dir[File.dirname(__FILE__) + '/lib/redmine_resources/patches/*_patch.rb'].each do |file|
    require_dependency file
  end

  Dir[File.dirname(__FILE__) + '/lib/redmine_resources/hooks/*_hook.rb'].each do |file|
    require_dependency file
  end
end

Redmine::Plugin.register :redmine_resources do
  name 'Resources plugin'
  author 'Gabriel Croitoru'
  description 'Redmine Resources Plugin'
  version '1.0.0'
  url 'http://gabrielcc.github.io/redmine_resources/'
  author_url 'http://gabrielcc.github.io/'

  # permission :view_resources_departments, :departments => [:index, :show]
  # permission :view_resources_resources, :resources => [:index, :show]
  # permission :edit_resources_departments, :departmens => [:edit, :destroy,  :new, :create]
  # permission :edit_resources_resources, :resources => [:edit, :destroy, :new, :create]

  # menu :admin_menu, :resources_departments, { :controller => 'departments', :action => 'index' }, :caption => 'Departments'
  # menu :admin_menu, :resources_resources, { :controller => 'resources', :action => 'index' }, :caption => 'Resources'
  # menu :project_menu, :resources_trackers, { :controller => 'trackers', :action => 'index'}, :caption => 'Resources'

  project_module :redmine_resources do
    permission :view_resources_plugin, { resources: [:index, :edit, :trackers] }, public: true
    # permission :view_resources_plugin, :resources => :index
    # permission :edit_resources_plugin, :resources => :edit
    # permission :config_resources_plugin, :resources => :trackers
  end
end
