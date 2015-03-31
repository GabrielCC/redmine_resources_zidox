require_dependency 'project'

module RedmineResources
  module Patches
    module ProjectPatch
      def self.included(base)
        base.class_eval do
          has_many :project_resource, dependent: :destroy
          has_many :resource, through: :project_resource
        end
      end
    end
  end
end

unless Project.included_modules.include? RedmineResources::Patches::ProjectPatch
  Project.send :include, RedmineResources::Patches::ProjectPatch
end
