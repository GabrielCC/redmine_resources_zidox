require File.expand_path('../../test_helper', __FILE__)

class IssuePatchTest < ActiveSupport::TestCase
  test 'Issue is patched with RedmineResources::Patches::IssuePatch' do
    patch = RedmineResources::Patches::IssuePatch
    assert_includes Issue.included_modules, patch
    %i().each do |method|
        assert_includes Issue.instance_methods, method
      end
  end

  # Custom field associated with tracker
  test 'creating a issue without initial estimation creates no resource' do
    create_base_setup
    issue = build_issue_with @tracker
    issue.save!
    assert_empty issue.issue_resource.all
    custom_value = issue.custom_values
      .where(custom_field_id: @custom_field.id).first
    assert_equal '', custom_value.value
  end

  test 'creating a issue with initial estimation creates a resource' do
    create_base_setup
    hours = 2
    issue = build_issue_with @tracker, inital_estimation: hours
    issue.save!
    resources = issue.issue_resource.all
    assert_not_empty resources
    assert_equal 1, resources.size
    resource = resources[0]
    assert_instance_of IssueResource, resource
    assert_equal hours, resource.estimation
    custom_value = issue.custom_values
      .where(custom_field_id: @custom_field.id).first.value
    assert_equal hours, custom_value
  end


  # manually_added_resource_estimation = false
  # test 'issue without estimation creates no resource' do
  #   issue = build_issue_with @root_tracker
  #   issue.save!
  #   assert_empty issue.issue_resource.all
  #   assert_equal nil, issue.estimated_hours
  # end

  # test 'issue with estimation creates one resource' do
  #   issue = build_issue_with @root_tracker, estimated_hours: @hours
  #   issue.save!
  #   resources = issue.issue_resource.all
  #   assert_not_empty resources
  #   assert_equal 1, resources.size
  #   resource = resources[0]
  #   assert_instance_of IssueResource, resource
  #   assert_equal @hours, resource.estimation
  #   assert_equal @hours, issue.estimated_hours
  # end

  # test 'issue with a child gets an estimation' do
  #   create_parent_and_child
  #   resources = @parent.issue_resource.all
  #   assert_not_empty resources
  #   assert_equal 1, resources.size
  #   resource = resources[0]
  #   assert_instance_of IssueResource, resource
  #   assert_equal @hours, resource.estimation
  #   assert_equal @hours, @parent.estimated_hours
  # end

  # test 'issue with a killed child looses the estimation' do
  #   create_parent_and_child
  #   @child.status = @status_killed
  #   @child.save!
  #   assert_empty @parent.issue_resource.all
  #   assert_equal nil, @parent.estimated_hours
  # end

  # test 'issue with a revived child gets the estimation back' do
  #   create_parent_and_child
  #   @child.status = @status_killed
  #   @child.save!
  #   assert_empty @parent.issue_resource.all
  #   @child.status = @status_new
  #   @child.save!
  #   resources = @parent.issue_resource.all
  #   assert_not_empty resources
  #   assert_equal 1, resources.size
  #   resource = resources[0]
  #   assert_instance_of IssueResource, resource
  #   assert_equal @hours, resource.estimation
  #   assert_equal @hours, @parent.estimated_hours
  # end

  # manually_added_resource_estimation = true
  # test 'issues with manual estimation do not get affected by children' do
  #   create_parent_and_child manual: true
  #   assert_empty @parent.issue_resource.all
  #   assert_equal @hours, @child.estimated_hours
  #   assert_equal nil, @parent.estimated_hours
  # end

  # test 'issues with manual estimation keep their estimation' do
  #   parent = build_issue_with @root_tracker
  #   parent.manually_added_resource_estimation = true
  #   parent.save!
  #   parent_estimation = 1
  #   issue_resource = IssueResource.create! issue_id: parent.id,
  #     resource_id: @resource.id, estimation: parent_estimation
  #   @child = build_issue_with @child_tracker, parent: parent,
  #     estimated_hours: @hours
  #   @child.save!
  #   resources = parent.issue_resource.all
  #   assert_not_empty resources
  #   assert_equal 1, resources.size
  #   resource = resources[0]
  #   assert_instance_of IssueResource, resource
  #   assert_equal parent_estimation, resource.estimation
  #   assert_equal parent_estimation, parent.estimated_hours
  # end
end
