require File.expand_path '../../test_helper', __FILE__

class IssuePatchTest < ActiveSupport::TestCase
  setup do
    create_base_setup
  end

  test 'Issue is patched with RedmineResources::Patches::IssuePatch' do
    patch = RedmineResources::Patches::IssuePatch
    assert_includes Issue.included_modules, patch
    %i(resources_with_divisions track_estimation_change
      calculate_resource_estimation_for_self recalculate_resources_for
      calculate_resource_estimation_for_parent recalculate_from_children
      ensure_current_issue_resource_for determine_resource_type_id
      update_estimation_for issue_gets_resources?).each do |method|
        assert_includes Issue.instance_methods, method
      end
  end

  test 'Issue without estimation creates no resource' do
    issue = build_issue_with @root_tracker
    p issue
    issue.save!
    assert_empty issue.resource.all
  end

  test 'Issue with estimation creates one resource' do
    hours = 12
    issue = build_issue_with @root_tracker, estimated_hours: hours
    issue.save!
    resources = issue.resource.all
    assert_not_empty resources
    assert resources.size == 1
    resource = resources[1]
    assert_instance_of Resource, resource
    asset resource.hours == hours
  end
end
