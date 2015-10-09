require File.expand_path('../../test_helper', __FILE__)

class IssuePatchTest < ActiveSupport::TestCase
  def expect_issue_to_have_a_resources_of(value)
    @found_resources = @issue.issue_resources.all
    assert_not_empty @found_resources
    assert_equal 1, @found_resources.size
    @found_resource = @found_resources[0]
    assert_instance_of IssueResource, @found_resource
    assert_equal value, @found_resource.estimation
  end

  def expect_issue_to_have_no_resources
    assert_empty @issue.issue_resources.all
  end

  def expect_issue_to_have_an_initial_estimation_of(value)
    custom_field = @issue.custom_values
      .where(custom_field_id: @custom_field.id).first
    custom_value = custom_field.value
    assert_equal value.to_s, custom_value
  end

  def expect_issue_with_initial_estimation_to_create_resource
    hours = 2
    create_issue_with_initial_estimation_of hours
    expect_issue_to_have_a_resources_of hours
    expect_issue_to_have_an_initial_estimation_of hours
  end

  def expect_issue_to_have_no_initial_estimation
    custom_field = @issue.custom_values
      .where(custom_field_id: @custom_field.id).first
    custom_value = custom_field.value
    assert custom_value.blank? || custom_value == '0',
      "Custom value expected to be blank or 0 but was #{ custom_value }"
  end

  test 'Issue is patched with RedmineResources::Patches::IssuePatch' do
    patch = RedmineResources::Patches::IssuePatch
    assert_includes Issue.included_modules, patch
    %i(resources_with_divisions set_issue_resource).each do |method|
        assert_includes Issue.instance_methods, method
      end
  end

  ## With plugin settings defined
  # Without default resource defined
  test 'without resource creating a issue is possible' do
    create_base_setup_without_resource_id
    create_issue_without_initial_estimation
    expect_issue_to_have_no_initial_estimation
  end

  test 'without resource creating a issue with estimation is possible' do
    create_base_setup_without_resource_id
    hours = 4
    create_issue_with_initial_estimation_of hours
    expect_issue_to_have_no_resources
    expect_issue_to_have_an_initial_estimation_of hours
  end

  test 'without resource adding an initial estimation is possible' do
    create_base_setup_without_resource_id
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

  # Without custom field defined
  test 'without custom field creating a issue is possible' do
    create_base_setup_without_custom_field
    @issue = build_issue_with @tracker
    @issue.save
    assert @issue.valid?
  end

  # Custom field associated with tracker
  test 'creating a issue without initial estimation creates no resource' do
    create_base_setup_with_settings
    create_issue_without_initial_estimation
    expect_issue_to_have_no_resources
    expect_issue_to_have_no_initial_estimation
  end

  test 'creating a issue with initial estimation creates a resource' do
    create_base_setup_with_settings
    expect_issue_with_initial_estimation_to_create_resource
  end

  test 'updating an initial estimation updated the resource' do
    create_base_setup_with_settings
    expect_issue_with_initial_estimation_to_create_resource
    new_estimation = 3
    @issue.update_attributes custom_field_values: {
      @custom_field.id => new_estimation }
    expect_issue_to_have_a_resources_of new_estimation
    expect_issue_to_have_an_initial_estimation_of new_estimation
  end

  test 'updating an initial estimation to 0 removes the resource' do
    create_base_setup_with_settings
    expect_issue_with_initial_estimation_to_create_resource
    new_estimation = 0
    @issue.update_attributes custom_field_values: {
      @custom_field.id => new_estimation }
    expect_issue_to_have_no_resources
    expect_issue_to_have_no_initial_estimation
  end

  test 'custom project settings are used when enabled' do
    create_base_setup_with_settings
    create_project_resource_settings
    hours = 2
    create_issue_with_initial_estimation_of hours
    expect_issue_to_have_a_resources_of hours
    expect_issue_to_have_an_initial_estimation_of hours
    assert_equal @project_resource.id, @found_resource.resource_id
  end

  test 'readonly custom fields does not create resource' do
    create_base_setup_with_settings
    create_project_resource_settings
    create_project_membership
    make_the_custom_field_read_only
    hours = 2
    create_issue_with_initial_estimation_of hours
    expect_issue_to_have_no_resources
    expect_issue_to_have_an_initial_estimation_of hours
  end
end
