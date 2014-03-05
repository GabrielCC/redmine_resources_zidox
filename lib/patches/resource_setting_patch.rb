
# Patches Redmine's Role dynamically.  Adds a relationship 
# Role +has_one+ to ResourceSetting
module ResourceSettingPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      has_one :resource_setting, :as => :setting_object      
    end

  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    def has_resources
      @resource ||= resource_setting
      return !@resource.nil?
    end

  end    
end
