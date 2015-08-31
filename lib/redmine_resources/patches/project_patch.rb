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

base = Project
patch = RedmineResources::Patches::ProjectPatch
base.send :include, patch unless base.included_modules.include? patch
