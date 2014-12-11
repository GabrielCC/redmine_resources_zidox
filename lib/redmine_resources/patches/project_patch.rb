require_dependency 'project'

module RedmineResources
  module Patches
    module ProjectPatch
      def self.included(base) # :nodoc:
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        # Same as typing in the class 
        base.class_eval do
          has_many :project_resource, dependent: :destroy
          has_many :resource, :through => :project_resource
        end

      end
      
      module ClassMethods
      end
      
      module InstanceMethods
      end    
    end
  end
end
