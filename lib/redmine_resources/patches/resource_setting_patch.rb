module RedmineResources
  module Patches
    module ResourceSettingPatch
      def self.included(base) # :nodoc:
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        # Same as typing in the class 
        base.class_eval do
          has_many :resource_setting, :as => :setting_object, dependent: :destroy
          has_many :instance_resource_setting, :as => :setting_object, dependent: :destroy
        end

      end
      
      module ClassMethods
      end
      
      module InstanceMethods
        def can_edit_resources(project)
          activated_resource_setting(project).editable(project).count > 0
          
        end

        def can_view_resources(project) 
          activated_resource_setting(project).visible(project).count > 0
        end


        def activated_resource_setting(project)
          if ResourceSetting.project_tracker_editable(project.id)
            self.resource_setting
          else
            self.instance_resource_setting
          end
        end
      end    
    end
  end
end
