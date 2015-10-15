require 'spec_helper'

describe Issue, type: :model do
  include SetupSupport

  it 'is patched with RedmineResources::Patches::IssuePatch' do
    patch = RedmineResources::Patches::IssuePatch
    expect(Issue.included_modules).to include(patch)
  end

  context 'with plugin settings defined' do
    context 'without default resource defined' do
      before :example do
        create_base_setup_without_resource_id
      end

      it 'creates an issue without estimation' do
        create_issue_without_initial_estimation
        expect_issue_to_have_no_initial_estimation
      end

      it 'creates an issue with estimation' do
        hours = 4
        create_issue_with_initial_estimation_of hours
        expect_issue_to_have_no_resources
        expect_issue_to_have_an_initial_estimation_of hours
      end

      it 'adds an initial estimation to issue' do
        hours = 4
        create_issue_with_initial_estimation_of hours
        expect_issue_to_have_no_resources
        expect_issue_to_have_an_initial_estimation_of hours
        new_estimation = 3
        @issue.update_attributes custom_field_values: {
          @custom_field.id => new_estimation }
        expect_issue_to_have_no_resources
        expect_issue_to_have_an_initial_estimation_of new_estimation
      end
    end

    context 'without custom field defined' do
      before :example do
        create_base_setup_without_custom_field
      end

      it 'creates an issue' do
        @issue = build_issue_with @tracker
        @issue.save
        expect(@issue).to be_valid
      end
    end

    context 'with custom field associated with trackers' do
      before :example do
        create_base_setup_with_settings
      end

      it 'creates no resource for issue without initial estimation' do
        create_issue_without_initial_estimation
        expect_issue_to_have_no_resources
        expect_issue_to_have_no_initial_estimation
      end

      it 'creates a resource for issue with initial estimation' do
        expect_issue_with_initial_estimation_to_create_resource
      end

      it 'updates the resource on issue update' do
        expect_issue_with_initial_estimation_to_create_resource
        new_estimation = 3
        @issue.update_attributes custom_field_values: {
          @custom_field.id => new_estimation }
        expect_issue_to_have_a_resources_of new_estimation
        expect_issue_to_have_an_initial_estimation_of new_estimation
      end

      it 'removes the resource when updating an initial estimation to 0' do
        expect_issue_with_initial_estimation_to_create_resource
        new_estimation = 0
        @issue.update_attributes custom_field_values: {
          @custom_field.id => new_estimation }
        expect_issue_to_have_no_resources
        expect_issue_to_have_no_initial_estimation
      end

      it 'uses custom project settings when enabled' do
        create_project_resource_settings
        hours = 2
        create_issue_with_initial_estimation_of hours
        expect_issue_to_have_a_resources_of hours
        expect_issue_to_have_an_initial_estimation_of hours
        expect(@found_resource.resource_id).to eq(@project_resource.id)
      end

      it 'does not create resource when custom field is readonly' do
        create_base_setup_with_settings
        create_project_resource_settings
        create_project_membership
        make_the_custom_field_read_only
        User.current = @author
        hours = 2
        create_issue_with_initial_estimation_of hours
        expect_issue_to_have_no_resources
        expect_issue_to_have_an_initial_estimation_of hours
      end

      it 'does not create resource when issue has manually added estimation' do
        create_base_setup_with_settings
        create_issue_without_initial_estimation
        expect_issue_to_have_no_resources
        expect_issue_to_have_no_initial_estimation
        @issue.update_attributes manually_added_resource_estimation: true
        hours = 8
        @issue.update_attributes custom_field_values: {
          @custom_field.id => hours }
        expect_issue_to_have_no_resources
        expect_issue_to_have_an_initial_estimation_of hours
      end
    end
  end
end
