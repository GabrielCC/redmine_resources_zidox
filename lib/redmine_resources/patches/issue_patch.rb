module RedmineResources
  module Patches
    module IssuePatch
      def self.included(base)
        base.send :include, InstanceMethods
        base.class_eval do
          has_many :issue_resource, dependent: :destroy
          has_many :resource, through: :issue_resource
          before_save :track_estimation_change
          before_destroy :track_estimation_change
          after_save :save_resource_estimation, if: -> { @resource_estimation_added }
          after_save :calculate_resource_estimation_for_self,
            if: -> { tracker_id == 2 && !Issue.where(parent_id: id).exists? }
          after_save :calculate_resource_estimation_for_parent
          after_destroy :calculate_resource_estimation_for_parent
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

        def track_estimation_change
          logger.debug "---track_estimation_change"
          if parent_issue_id != parent_id
            logger.debug "Parent changed!"
            @parent_changed = true
            @old_parent_id = parent_id
            logger.debug "Old Parent ID: #{@old_parent_id}"
            @new_parent_id = parent_issue_id
            logger.debug "New Parent ID: #{@new_parent_id}"
          else
            logger.debug "Parent not changed!"
            @old_parent_id = parent_issue_id
          end
          @old_estimation = estimated_hours_was.to_i
          logger.debug "Old estimation: #{@old_estimation}"
          @new_estimation = estimated_hours.to_i
          logger.debug "New estimation: #{@new_estimation}"
        end

        def calculate_resource_estimation_for_self
          logger.debug "---calculate_resource_estimation_for_self"
          return true if @new_estimation == 0 || !issue_gets_resources?(self)
          issue_resource.all.each {|res| res.destroy } unless manually_added_resource_estimation
          altered_resource = ensure_current_issue_resource_for id
          logger.debug "altered_resource #{altered_resource.inspect}"
          altered_resource.estimation = @new_estimation
          altered_resource.save
        end

        def recalculate_resources_for(parent_id)
          logger.debug "---recalculate_resources_for #{parent_id}"
          parent_issue = Issue.where(id: parent_id).first || return
          return unless issue_gets_resources?(parent_issue)
          logger.debug "Parent found"
          ensure_current_issue_resource_for parent_issue
          parent_issue.estimated_hours = 0
          parent_issue.issue_resource.all.each do |res|
            recalculate_from_children res, parent_issue
          end
          update_estimation_for parent_issue
        end

        def calculate_resource_estimation_for_parent
          logger.debug "---calculate_resource_estimation_for_parent"
          recalculate_resources_for @old_parent_id if @old_parent_id
          recalculate_resources_for @new_parent_id if @new_parent_id
        end

        def ensure_current_issue_resource_for(issue_id)
          logger.debug "---ensure_current_issue_resource_for #{issue_id}"
          res = IssueResource.where(issue_id: issue_id,
            resource_id: determine_resource_type_id
          ).first_or_create(estimation: @new_estimation)
          res.estimation = @new_estimation
          res.save
          res
        end

        def recalculate_from_children(res, parent_issue)
          logger.debug "---recalculate_from_children #{res.inspect}, #{parent_issue.inspect}"
          issues = Issue.where(parent_id: parent_issue.id)
            .where('issues.status_id NOT IN (?)', [6,23])
            .select([:estimated_hours, :assigned_to_id, :author_id])
          estimated = 0
          issues.each do |issue|
            user_email = User.where(id: (issue.assigned_to_id || issue.author_id)).pluck(:mail).first
            logger.debug "user_email: #{user_email}"
            next unless user_email
            project_resource = ProjectResourceEmail.where(project_id: project_id, email: user_email).first
            logger.debug "project_resource: #{project_resource.inspect}"
            next unless project_resource
            user_resource_id = project_resource.resource_id
            logger.debug "user_resource_id: #{user_resource_id}"
            next unless user_resource_id
            estimated += issue.estimated_hours if user_resource_id == res.resource_id
            logger.debug "estimated: #{estimated}"
          end
          res.estimation = estimated.to_i
          logger.debug "Res: #{res.inspect}"
          res.estimation == 0 ? res.destroy : res.save
        end

        def determine_resource_type_id
          logger.debug "---determine_resource_type_id"
          user_email = User.where(id: (assigned_to_id || author_id)).pluck(:mail).first
          logger.debug "user_email: #{user_email}"
          return unless user_email
          project_resource = ProjectResourceEmail.where(project_id: project_id, email: user_email).first
          logger.debug "project_resource: #{project_resource.inspect}"
          return unless project_resource
          project_resource.resource_id
        end

        def update_estimation_for(parent_issue)
          logger.debug "---update_estimation_for #{parent_issue.inspect}"
          logger.debug "Blocked? #{parent_issue.blocked?}"
          return if parent_issue.blocked?
          children_estimation_total = Issue.where(
              'issues.tracker_id NOT IN (2,5,6) AND parent_id = ?', parent_issue.id
            ).sum(:estimated_hours).to_i
          children_estimation_total += Issue.where(parent_id: @parent_id, tracker_id: 2)
            .sum(:estimated_hours).to_i if parent.tracker_id == 5
          logger.debug "children_estimation_total: #{children_estimation_total}"
          parent.update_column :estimated_hours, children_estimation_total
          parent.update_estimation_for(parent.parent) if parent.parent_id
          logger.debug "Parent column updated"
        end

        def issue_gets_resources?(issue)
          logger.debug "---issue_gets_resources? #{issue.inspect}"
          logger.debug "Manual estimation: #{issue.manually_added_resource_estimation}"
          return false if issue.manually_added_resource_estimation
          trackers_with_resources = ResourceSetting.where(project_id: project_id,
            setting: 1, setting_object_type: 'Tracker').pluck(:setting_object_id)
          logger.debug "Trackers with resources: #{trackers_with_resources}"
          logger.debug "Issue tracker_id: #{issue.tracker_id}"
          trackers_with_resources.include?(issue.tracker_id)
        end
      end
    end
  end
end

unless Issue.included_modules.include? RedmineResources::Patches::IssuePatch
  Issue.send :include, RedmineResources::Patches::IssuePatch
end
