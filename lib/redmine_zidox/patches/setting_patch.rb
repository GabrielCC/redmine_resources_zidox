module RedmineZidox
  module Patches
    module SettingPatch
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def plugin_redmine_zidox_for_project(project)
          settings = initialize_project_settings project
          if settings['custom']
            settings
          else
            Setting.plugin_redmine_zidox
          end
        end

        def initialize_project_settings(project)
          setting_name = "plugin_redmine_zidox_project_#{ project.id }"
          begin
            settings = Setting.send setting_name
          rescue NoMethodError
            Setting.define_setting setting_name, 'serialized' => true
            settings = Setting.send setting_name
          end
          settings = {} if !settings || settings.blank?
          settings['visible'] = {} unless settings['visible']
          settings['editable'] = {} unless settings['editable']
          settings
        end
      end
    end
  end
end

base = Setting
patch = RedmineZidox::Patches::SettingPatch
base.send :include, patch unless base.included_modules.include? patch
