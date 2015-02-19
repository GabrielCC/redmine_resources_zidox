module RedmineResources
  module Patches
    module IssuePatch
      def self.included(base)
        base.send :include, InstanceMethods
        base.class_eval do
          has_many :issue_resource, dependent: :destroy
          has_many :resource, through: :issue_resource
          validate :validate_resources_workflow
          before_save :mark_resource_estimation_added
          after_save :add_resource_estimation, if: -> { resource_estimation_added? }
        end
      end

      module InstanceMethods
        def resources_with_departments
          list = IssueResource.includes(resource: :department).where(issue_id: self.id)
          result = {}
          list.each do |element|
            department_name = element.resource.department.name
            result[department_name] = [] unless result[department_name]
            result[department_name] << element
          end
          result
        end

        def list_resources_workflow
          ResourcesWorkflow.where(project_id: project_id, old_status_id: status_id)
            .pluck(:new_status_id)
        end

        def validate_resources_workflow
          rules_count = ResourcesWorkflow.where(
            project_id: project_id,
            old_status_id: status_id_was,
            new_status_id: status_id
          ).count
          return true unless rules_count > 0 && tracker.can_view_resources(project)
          if self.resource.count == 0
            errors.add(:base, 'Required resource estimation')
            return false
          end
        end

        def mark_resource_estimation_added
          @estimation_added = estimated_hours_changed? ? :added : :not_added
        end

        def add_resource_estimation
          IssueResource.from_params({
            project_id: project_id,
            issue_id: id,
            resource_id: determine_resource_type_id,
            estimation: estimated_hours
          })
        end

        def resource_estimation_added?
          @estimation_added == :added
        end

        def determine_resource_type_id
          user_id = assigned_to_id || author_id
          member = Member.where(user_id: user_id, project_id: project_id).first
          member.resource.id
        end
      end
    end
  end
end

unless Issue.included_modules.include? RedmineResources::Patches::IssuePatch
  Issue.send :include, RedmineResources::Patches::IssuePatch
end
