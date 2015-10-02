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
          after_save :calculate_resource_estimation_for_self,
            if: -> { [2, 13].include?(tracker_id) && !Issue.where(parent_id: id).exists? }
          after_save :calculate_resource_estimation_for_parent
          after_destroy :calculate_resource_estimation_for_parent
        end
      end

      module InstanceMethods
        def resources_with_divisions
          list = IssueResource.includes(resource: :division).where(issue_id: self.id)
          result = {}
          list.each do |element|
            division_name = element.resource.division.name
            result[division_name] = [] unless result[division_name]
            result[division_name] << element
          end
          result
        end

        def track_estimation_change
          if parent_issue_id != parent_id
            @parent_changed = true
            @old_parent_id = parent_id
            @new_parent_id = parent_issue_id
          else
            @old_parent_id = parent_issue_id
          end
          @old_estimation = estimated_hours_was.to_i
          @new_estimation = estimated_hours.to_i
        end

        def calculate_resource_estimation_for_self
          return true if @new_estimation == 0 || !issue_gets_resources?(self)
          issue_resource.all.each {|res| res.destroy } unless manually_added_resource_estimation
          altered_resource = ensure_current_issue_resource_for id
          altered_resource.estimation = @new_estimation
          altered_resource.save
        end

        def recalculate_resources_for(parent_id)
          parent_issue = Issue.where(id: parent_id).first || return
          return unless issue_gets_resources?(parent_issue)
          ensure_current_issue_resource_for parent_issue
          parent_issue.estimated_hours = 0
          parent_issue.issue_resource.all.each do |res|
            recalculate_from_children res, parent_issue
          end
          update_estimation_for parent_issue
        end

        def calculate_resource_estimation_for_parent
          recalculate_resources_for @old_parent_id if @old_parent_id
          recalculate_resources_for @new_parent_id if @new_parent_id
        end

        def ensure_current_issue_resource_for(issue_id)
          res = IssueResource.where(issue_id: issue_id,
            resource_id: determine_resource_type_id
          ).first_or_create(estimation: @new_estimation)
          res.estimation = @new_estimation
          res.save
          res
        end

        def recalculate_from_children(res, parent_issue)
          issues = Issue.where(parent_id: parent_issue.id)
            .where('issues.status_id NOT IN (?)', [6,23])
            .select([:estimated_hours, :assigned_to_id, :author_id])
          estimated = 0
          issues.each do |issue|
            user_login = User.where(id: issue.assigned_to_id).pluck(:login).first
            project_resource = ProjectResourceEmail.where(project_id: project_id, login: user_login).first if user_login
            unless project_resource
              user_login = User.where(id: issue.author_id).pluck(:login).first
              project_resource = ProjectResourceEmail.where(project_id: project_id, login: user_login).first if user_login
            end
            next unless project_resource
            user_resource_id = project_resource.resource_id
            next unless user_resource_id
            estimated += issue.estimated_hours.to_i if user_resource_id == res.resource_id
          end
          res.estimation = estimated.to_i
          res.estimation == 0 ? res.destroy : res.save
        end

        def determine_resource_type_id
          user_login = User.where(id: assigned_to_id).pluck(:login).first
          project_resource = ProjectResourceEmail.where(project_id: project_id, login: user_login).first if user_login
          unless project_resource
            user_login = User.where(id: author_id).pluck(:login).first
            project_resource = ProjectResourceEmail.where(project_id: project_id, login: user_login).first if user_login
          end
          return unless project_resource
          project_resource.resource_id
        end

        def update_estimation_for(parent_issue)
          return if parent_issue.blocked?
          children_estimation_total = Issue.where(
              'issues.tracker_id NOT IN (2,5,6,13) AND parent_id = ?', parent_issue.id
            ).sum(:estimated_hours).to_i
          children_estimation_total += Issue.where(parent_id: parent_issue.id, tracker_id: [2, 13])
            .sum(:estimated_hours).to_i if parent_issue.tracker_id == 5
          parent_issue.update_column :estimated_hours, children_estimation_total
          parent_issue.update_estimation_for(parent_issue.parent) if parent_issue.parent_id
        end

        def issue_gets_resources?(issue)
          return false if issue.manually_added_resource_estimation
          trackers_with_resources = ResourceSetting.where(project_id: issue.project_id,
            setting: 1, setting_object_type: 'Tracker').pluck(:setting_object_id)
          trackers_with_resources.include?(issue.tracker_id)
        end
      end
    end
  end
end

base = Issue
patch = RedmineResources::Patches::IssuePatch
base.send :include, patch unless base.included_modules.include? patch
