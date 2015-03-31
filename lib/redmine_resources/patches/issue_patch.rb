module RedmineResources
  module Patches
    module IssuePatch
      def self.included(base)
        base.send :include, InstanceMethods
        base.class_eval do
          has_many :issue_resource, dependent: :destroy
          has_many :resource, through: :issue_resource
          before_save :keep_estimation_value
          before_save :add_resource_estimation_to_parent, if: -> { parent_gets_resources? }
          after_save :add_resource_estimation_to_self, if: -> do
            tracker_id == 2 && !Issue.where(parent_id: id).exists?
          end
          after_save :save_resource_estimation, if: -> { @resource_estimation_added }
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

        def keep_estimation_value
          @old_value = estimated_hours_was
          @estimation_value = estimated_hours
        end

        def add_resource_estimation_to_self
          resource_id = determine_resource_type_id
          @altered_resource = find_issue_resource id
          @altered_resource.estimation = @estimation_value.to_i
          mode = @altered_resource.new_record? ? :create : :update
          @altered_resource.save!
          return true unless @current_journal
          @current_journal.details << @altered_resource.journal_entry(mode, @old_value)
        end

        def add_resource_estimation_to_parent
          estimation = find_total_estimated_hours_for_resource
          estimation += estimated_hours.to_i unless [6,23].include?(status_id)
          @altered_resource = find_issue_resource parent_id
          old_value = estimated_hours_was.to_i
          mode = nil
          if estimation == 0
              @altered_resource.destroy
              mode = :destroy
          else
            @altered_resource.estimation = estimation
            mode = @altered_resource.new_record? ? :create : :update
            if new_record?
              @resource_estimation_added = true
            else
              save_resource_estimation
            end
          end
          estimated_hours = estimation
          return true unless @current_journal && mode
          @current_journal.details << @altered_resource.journal_entry(mode, old_value)
        end

        def save_resource_estimation
          @altered_resource.save!
        end

        def find_issue_resource(id)
          IssueResource.where(issue_id: id,
            resource_id: determine_resource_type_id
          ).first_or_create!(estimation: 1)
        end

        def find_total_estimated_hours_for_resource
          issues = Issue.where('issues.parent_id = ? AND issues.id <> ? AND issues.status_id NOT IN (?) AND issues.assigned_to_id IS NOT NULL', parent_id, id, [6,23])
          resource_id = determine_resource_type_id
          estimated = 0
          issues.each do |issue|
            member = Member.where(user_id: issue.assigned_to_id, project_id: project_id).first
            next unless member
            member_resource = member.resource
            next unless member_resource
            estimated += issue.estimated_hours if member_resource.id == resource_id
          end
          estimated.to_i
        end

        def determine_resource_type_id
          user_id = assigned_to_id || User.current.id
          member = Member.where(user_id: user_id, project_id: project_id).first
          return nil unless member
          member_resource = member.resource
          member_resource ? member_resource.id : nil
        end

        def update_parent_estimation
          parent = Issue.where(id: parent_id).first
          return if !parent || parent.blocked?
          children_estimation_total = Issue.where(
              'issues.tracker_id NOT IN (2,5,6) AND parent_id = ?', parent.id
            ).sum(:estimated_hours).to_i
          children_estimation_total += Issue.where(parent_id: parent.id, tracker_id: 2)
            .sum(:estimated_hours).to_i if parent.tracker_id == 5
          parent.update_column :estimated_hours, children_estimation_total
          parent.update_parent_estimation
        end

        def parent_gets_resources?
          return false unless parent_id
          trackers_with_resources = ResourceSetting.where(project_id: project_id,
            setting: 1, setting_object_type: 'Tracker').pluck(:setting_object_id)
          !trackers_with_resources.include?(tracker_id) && ![2,5,6].include?(tracker_id)
        end
      end
    end
  end
end

unless Issue.included_modules.include? RedmineResources::Patches::IssuePatch
  Issue.send :include, RedmineResources::Patches::IssuePatch
end
