require_dependency 'member'

module RedmineResources
  module Patches
    module MembershipPatch
      def self.included(base)
        base.class_eval do
          has_one :member_resource, dependent: :destroy
          has_one :resource, :through => :member_resource
          # validates :resource, presence: { message: ' cannot be blank' },
            # if: proc { |a| a.project.module_enabled? 'redmine_resources' }
        end
      end
    end
  end
end

unless Member.included_modules.include? RedmineResources::Patches::MembershipPatch
  Member.send :include, RedmineResources::Patches::MembershipPatch
end
