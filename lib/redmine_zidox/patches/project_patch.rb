module RedmineZidox
  module Patches
    module ProjectPatch
      def self.included(base)
        base.send :include, InstanceMethods
        base.class_eval do
          has_many :project_resources, dependent: :destroy
          has_many :resources, through: :project_resources
        end
      end
    end

    module InstanceMethods
      def resources_list(issue)
        resources.all - issue.resources.all
      end
    end
  end
end

base = Project
patch = RedmineZidox::Patches::ProjectPatch
base.send :include, patch unless base.included_modules.include? patch
