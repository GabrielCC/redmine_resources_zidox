module RedmineResources
  module Patches
    module TrackerPatch
      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        def gets_resources?(project)
          settings = Setting.plugin_redmine_zidox
          custom_field_id = settings['custom_field_id']
          current_custom_field = CustomField.where(id: custom_field_id).first
          tracker_ids = current_custom_field.trackers.pluck(:id)
          tracker_ids.include? id
        end
      end
    end
  end
end

base = Tracker
patch = RedmineResources::Patches::TrackerPatch
base.send :include, patch unless base.included_modules.include? patch
