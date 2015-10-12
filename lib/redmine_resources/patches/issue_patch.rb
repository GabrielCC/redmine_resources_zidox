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
              division = element.resource.division
              division_id = division.id
              total[division_id] = { name: division.name, elements: [] } unless total[division_id]
              total[division_id][:elements] << { id: element.id,
                estimation: element.estimation, code: element.resource.code }
              total
            end
        end

        def set_issue_resource
          return if manually_added_resource_estimation
          custom_field_id = Setting.plugin_redmine_resources[:custom_field_id]
          resource_id = resource_id_from_settings
          default_resource = Resource.where(id: resource_id).first
          return unless default_resource
          custom_field = custom_values.where(custom_field_id: custom_field_id)
            .first
          return unless custom_field
          return if custom_field_read_only_for_al_roles custom_field_id
          custom_value = custom_field.value
          if custom_value.blank? || custom_value == '0'
            issue_resources.where(resource_id: default_resource.id).destroy_all
          else
            resource = issue_resources.where(resource_id: default_resource.id)
              .first_or_initialize
            resource.assign_attributes(estimation: custom_value.to_i)
            resource.save!
          end
        end

        private

        def custom_field_read_only_for_al_roles(custom_field_id)
          editable_custom_field_values(User.current).reject do |value|
            value.custom_field.id != custom_field_id.to_i
          end.count == 0
        end

        def resource_id_from_settings
          setting_name = "plugin_redmine_resources_project_#{ project_id }"
          begin
            project_settings = Setting.send setting_name
          rescue NoMethodError
            Setting.define_setting setting_name, 'serialized' => true
            project_settings = Setting.send setting_name
          end
          project_settings = {} if !project_settings || project_settings.blank?
          if project_settings['custom'] == '1'
            project_settings['resource_id']
          else
            Setting.plugin_redmine_resources[:resource_id]
          end
        end
      end
    end
  end
end

base = Issue
patch = RedmineResources::Patches::IssuePatch
base.send :include, patch unless base.included_modules.include? patch
