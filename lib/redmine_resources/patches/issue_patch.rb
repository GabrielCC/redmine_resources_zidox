module RedmineResources
  module Patches
    module IssuePatch
      def self.included(base)
        base.send :include, InstanceMethods
        base.class_eval do
          has_many :issue_resources, dependent: :destroy
          has_many :resources, through: :issue_resources
          after_save :set_issue_resource
        end
      end

      module InstanceMethods
        def resources_with_divisions
          IssueResource.includes(resource: :division)
            .where(issue_id: self.id)
            .reduce({}) do |total, element|
              division_name = element.resource.division.name
              total[division_name] = [] unless total[division_name]
              total[division_name] << element
              total
            end
        end

        def set_issue_resource
          resource_id = Setting.plugin_redmine_resources[:resource_id]
          custom_field_id = Setting.plugin_redmine_resources[:custom_field_id]
          default_resource = Resource.where(id: resource_id).first
          custom_value = custom_values.where(custom_field_id: custom_field_id)
            .first.value
          if custom_value.blank? || custom_value == '0'
            issue_resources.where(resource_id: default_resource.id).destroy_all
          else
            resource = issue_resources.where(resource_id: default_resource.id)
              .first_or_initialize
            resource.assign_attributes(estimation: custom_value.to_i)
            resource.save!
          end
        end
      end
    end
  end
end

base = Issue
patch = RedmineResources::Patches::IssuePatch
base.send :include, patch unless base.included_modules.include? patch
