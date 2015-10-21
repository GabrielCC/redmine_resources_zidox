module RedmineResources
  module Patches
    module ApplicationHelperPatch
      def self.included(base)
        base.class_eval do
          def authorize_globally_for(controller, action)
            User.current.allowed_to_globally?({ controller: controller,
              action: action }, {})
          end

          def resources_visible(issue)
            project = issue.project
            return false unless issue.tracker.gets_resources?(project)
            return true if User.current.admin?
            User.current.can_view_resources? project
          end

          def resources_editable(issue)
            project = issue.project
            return false unless issue.tracker.gets_resources?(project)
            return true if User.current.admin?
            User.current.can_edit_resources? project, issue
          end
        end
      end
    end
  end
end

base = ApplicationHelper
patch = RedmineResources::Patches::ApplicationHelperPatch
base.send :include, patch unless base.included_modules.include? patch
