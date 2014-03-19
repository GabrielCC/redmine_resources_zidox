
# Patches Redmine's Role dynamically.  Adds a relationship 
# Role +has_one+ to ResourceSetting
module IssuePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      has_many :issue_resource, dependent: :destroy
      has_many :resource, :through => :issue_resource
      validate :resources_workflow
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

    def resources_workflow
      rules = ResourcesWorkflow.where({
        :project_id => self.project_id, 
        :old_status_id => self.status_id_was, 
        :new_status_id => self.status_id
      })
      unless rules.count > 0 
        if self.resource.count == 0
          errors.add(:base, 'Required resource estimation')
          return false
        end
      end
      return true
    end
  end    
end
