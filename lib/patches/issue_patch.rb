
# Patches Redmine's Role dynamically.  Adds a relationship 
# Role +has_one+ to ResourceSetting
module IssuePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      has_many :issue_resource
      has_many :resource, :through => :issue_resource
    end

  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    def resources_with_departments
      list = IssueResource.includes(resource: :department).where(:issue_id => self.id)
      result = {}
      list.each{|e|
        department_name = e.resource.department.name 
        result[department_name] = [] if result[department_name].nil?
        result[department_name] << e 
      }
      result
    end

  end    
end
