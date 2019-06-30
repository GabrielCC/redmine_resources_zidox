module RedmineResources
  module Patches
    module UserPatch
      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        def can_view_resources?(project)
          return true if User.current.admin?
          role_ids = role_ids_for_project project
          any_roles_in_settings? role_ids, project,'visible'
        end

        def can_edit_resources?(project, issue)
          return true if User.current.admin?
          role_ids = role_ids_for_project project
          return false if issue.custom_field_read_only_for_al_roles
          any_roles_in_settings? role_ids, project,'editable'
        end

        private

        def role_ids_for_project(project)
          roles_for_project(project).map(&:id).map(&:to_s)
        end

        def any_roles_in_settings?(role_ids, project, setting_name)
          settings = Setting.plugin_redmine_zidox_for_project project
          accessible = settings[setting_name]
          setting_ids = accessible ? accessible.keys : []
          role_ids.each {|role_id| return true if setting_ids.include? role_id }
          false
        end
      end
    end
  end
end

base = User
patch = RedmineResources::Patches::UserPatch
base.send :include, patch unless base.included_modules.include? patch
