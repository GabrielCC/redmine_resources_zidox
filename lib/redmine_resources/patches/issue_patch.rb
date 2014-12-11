module RedmineResources
  module Patches
    module IssuePatch
      def self.included(base) # :nodoc:
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        # Same as typing in the class 
        base.class_eval do
          has_many :issue_resource, dependent: :destroy
          has_many :resource, :through => :issue_resource
          validate :validate_resources_workflow
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
        def list_resources_workflow
          if ResourceSetting.project_workflow_editable(project_id)
            ResourcesWorkflow.where({
              :project_id => self.project_id, 
              :old_status_id => self.status_id
            }).pluck(:new_status_id)
          else
            InstanceResourcesWorkflow.where({
              :old_status_id => self.status_id_was, 
               :old_status_id => self.status_id
            }).pluck(:new_status_id)
          end
        end

        def validate_resources_workflow
          trackers = self.tracker
          rules = get_resources_workflow_rules
          if rules.count > 0 && trackers.can_view_resources(self.project)
            if self.resource.count == 0
              errors.add(:base, 'Required resource estimation')
              return false
            end
          end
          return true
        end

        def get_resources_workflow_rules
          if ResourceSetting.project_workflow_editable(project_id)
            ResourcesWorkflow.where({
              :project_id => self.project_id, 
              :old_status_id => self.status_id_was, 
              :new_status_id => self.status_id
            })
          else
            InstanceResourcesWorkflow.where({
              :old_status_id => self.status_id_was, 
              :new_status_id => self.status_id
            })        
          end
        end
      end    
    end
  end
end
