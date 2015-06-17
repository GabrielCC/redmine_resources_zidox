module RedmineResources
  module Patches
    module UserPatch
      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        def resource_names
          @resource_names ||= resources.map do |resource|
              "#{ resource.name }, #{ resource.code }, #{ resource.division.name }"
            end.join(', ')
        end

        def resources
          Resource.joins('INNER JOIN project_resources ON project_resources.resource_id = resources.id')
            .joins('INNER JOIN projects ON projects.id = project_resources.project_id')
            .joins('INNER JOIN project_resource_emails ON project_resource_emails.project_id = projects.id AND project_resource_emails.resource_id = resources.id')
            .joins('INNER JOIN members ON members.project_id = projects.id')
            .joins('INNER JOIN users ON users.id = members.user_id ')
            .where('users.id = ?', id)
            .where('project_resource_emails.email = ?', mail)
            .select('DISTINCT resources.name, resources.code')
            .includes(:division)
        end
      end
    end
  end
end

unless User.included_modules.include? RedmineResources::Patches::UserPatch
  User.send :include, RedmineResources::Patches::UserPatch
end
