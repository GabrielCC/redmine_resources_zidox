require_dependency 'member'

# Patches Redmine's Member dynamically.  Adds a relationship 
# Member +has_one+ to Resource
module MembershipPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      has_one :member_resource
      has_one :resource, :through => :member_resource
      
    end

  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end    
end
