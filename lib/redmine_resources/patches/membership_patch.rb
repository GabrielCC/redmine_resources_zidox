require_dependency 'member'

module RedmineResources
  module Patches
    module MembershipPatch
      def self.included(base) # :nodoc:
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        # Same as typing in the class 
        base.class_eval do
          has_one :member_resource, dependent: :destroy
          has_one :resource, :through => :member_resource
          # validates :resource, :presence => { :message => " cannot be blank" }, if: Proc.new { |a| a.project.module_enabled?("redmine_resources") }
        end

      end
      
      module ClassMethods
      end
      
      module InstanceMethods
      end    
    end
  end
end
