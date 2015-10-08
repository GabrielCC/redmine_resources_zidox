module RedmineResources
  module Patches
    module IssuePatch
      def self.included(base)
        base.send :include, InstanceMethods
        base.class_eval do
          has_many :issue_resources, dependent: :destroy
          has_many :resource, through: :issue_resources
          after_save :create_issue_resource
        end
      end

      module InstanceMethods
        def create_issue_resource
          resource_id = Setting.plugin_redmine_resources[:resource_id]
          custom_field_id = Setting.plugin_redmine_resources[:custom_field_id]
          default_resource = Resource.where(id: resource_id).first
          custom_value = custom_values.where(custom_field_id: custom_field_id)
            .first
          issue_resources.create resource_id: default_resource.id,
            estimation: custom_value.value.to_i
        end
      end
    end
  end
end

base = Issue
patch = RedmineResources::Patches::IssuePatch
base.send :include, patch unless base.included_modules.include? patch
