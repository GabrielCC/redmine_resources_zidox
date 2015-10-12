require File.expand_path('../../test_helper', __FILE__)

class IssueResourcesControllerTest < ActionController::TestCase
  def create_test_setup
    create_base_setup_with_settings
    login_as_author
    create_issue_without_initial_estimation
  end

  def create_existing_issue_resource_of(value)
    @issue_resource = create :issue_resource, issue_id: @issue.id,
      resource_id: @resource.id, estimation: @hours
  end

  test 'POST #create as JSON' do
    create_test_setup
    @hours = 2
    post :create, format: :json, issue_resource: { project_id: @project.id,
        issue_id: @issue.id, estimation: @hours, resource_id: @resource.id }
    assert_response :success
  end

  test 'POST #create as JSON twice with the same data returns 400' do
    create_test_setup
    @hours = 2
    data = { format: :json, issue_resource: { project_id: @project.id,
        issue_id: @issue.id, estimation: @hours, resource_id: @resource.id } }
    post :create, data
    assert_response :success
    post :create, data
    assert_response :bad_request
  end

  test 'PUT #update as JSON' do
    create_test_setup
    @hours = 2
    create_existing_issue_resource_of @hours
    @new_estimation = 3
    put :update, format: :json, id: @issue_resource.id,
      issue_resource: { estimation: @new_estimation }
    assert_response :success
  end

  test 'DELETE #destroy as JSON' do
    create_test_setup
    @hours = 2
    create_existing_issue_resource_of @hours
    delete :destroy, format: :json, id: @issue_resource.id
    assert_response :success
  end
end
