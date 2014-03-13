
# Patches Redmine's Role dynamically.  Adds a relationship 
# Role +has_many+ to ResourceSetting
module ResourceSettingPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      has_many :resource_setting, :as => :setting_object, dependent: :destroy
    end

  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    def can_edit_resources(project)
      self.resource_setting.editable(project).count > 0
    end

    def can_view_resources(project) 
      self.resource_setting.visible(project).count > 0
    end

  end    
end
