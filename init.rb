require "redmine"

# Patches to the Redmine core.
ActionDispatch::Callbacks.to_prepare do 
  require_dependency 'member'
  require 'redmine_resources/patches/membership_patch'
  # Guards against including the module multiple time (like in tests)
  # and registering multiple callbacks
  unless Member.included_modules.include? RedmineResources::Patches::MembershipPatch
    Member.send(:include, RedmineResources::Patches::MembershipPatch)
  end

  require_dependency 'project'
  require 'redmine_resources/patches/project_patch'
  # Guards against including the module multiple time (like in tests)
  # and registering multiple callbacks
  unless Project.included_modules.include? RedmineResources::Patches::ProjectPatch
    Project.send(:include, RedmineResources::Patches::ProjectPatch)
  end

  require_dependency 'role'
  require 'redmine_resources/patches/resource_setting_patch'
  # Guards against including the module multiple time (like in tests)
  # and registering multiple callbacks
  unless Role.included_modules.include? RedmineResources::Patches::ResourceSettingPatch
    Role.send(:include, RedmineResources::Patches::ResourceSettingPatch)
  end

  require_dependency 'tracker'
  # Guards against including the module multiple time (like in tests)
  # and registering multiple callbacks
  unless Tracker.included_modules.include? RedmineResources::Patches::ResourceSettingPatch
    Tracker.send(:include, RedmineResources::Patches::ResourceSettingPatch)
  end

  require_dependency 'members_controller'
  require 'redmine_resources/patches/members_controller_patch'
  unless MembersController.included_modules.include? RedmineResources::Patches::MembersControllerPatch
    MembersController.send(:include, RedmineResources::Patches::MembersControllerPatch)
  end

  require_dependency 'issue'
  require 'redmine_resources/patches/issue_patch'
  unless Issue.included_modules.include? RedmineResources::Patches::IssuePatch
    Issue.send(:include, RedmineResources::Patches::IssuePatch)
  end

  require 'redmine_resources/patches/application_helper_patch'
  require_dependency 'application_helper'
  ApplicationHelper.send(:include, RedmineResources::Patches::ApplicationHelperPatch) unless ApplicationHelper.included_modules.include? RedmineResources::Patches::ApplicationHelperPatch

  require 'redmine_resources/patches/issues_helper_patch'
  require_dependency 'issues_helper'
  IssuesHelper.send(:include, RedmineResources::Patches::IssuesHelperPatch) unless IssuesHelper.included_modules.include? RedmineResources::Patches::IssuesHelperPatch

end

Redmine::Plugin.register :redmine_resources do
  name 'Resources plugin'
  author 'Gabriel Croitoru'
  description 'Redmine Resources Plugin'
  version '1.0.0'
  url 'http://gabrielcc.github.io/redmine_resources/'
  author_url 'http://gabrielcc.github.io/'
  
  # Patches to the Redmine core.

  require 'redmine_resources/hook_listener'


  # permission :view_resources_departments, :departments => [:index, :show]
  # permission :view_resources_resources, :resources => [:index, :show]
  # permission :edit_resources_departments, :departmens => [:edit, :destroy,  :new, :create]
  # permission :edit_resources_resources, :resources => [:edit, :destroy, :new, :create]


   menu :admin_menu, :resources_workflows, { :controller => 'resources_workflows', :action => 'index' }, :caption => 'Resources Workflows'
   menu :admin_menu, :resources_settings, { :controller => 'resources_settings', :action => 'index' }, :caption => 'Resources Settings'
  # menu :admin_menu, :resources_resources, { :controller => 'resources', :action => 'index' }, :caption => 'Resources'
  # menu :project_menu, :resources_trackers, { :controller => 'trackers', :action => 'index'}, :caption => 'Resources'

  project_module :redmine_resources do
    permission :view_resources_plugin, { :resources => [:index, :edit, :trackers] }, :public => true
    # permission :view_resources_plugin, :resources => :index
    # permission :edit_resources_plugin, :resources => :edit
    # permission :config_resources_plugin, :resources => :trackers
  end
end