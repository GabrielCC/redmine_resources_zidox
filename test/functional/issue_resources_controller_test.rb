require File.expand_path('../../test_helper', __FILE__)

class IssueResourcesControllerTest < ActionController::TestCase
  def create_test_setup
    create_base_setup_with_settings
    create_project_membership
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
    data = { format: :json, key: @author.api_key, issue_resource: {
        project_id: @project.id, issue_id: @issue.id, estimation: @hours,
        resource_id: @resource.id } }
    post :create, data
    assert_response :success
  end

  test 'POST #create as JSON twice with the same data returns 400' do
    create_test_setup
    @hours = 2
    data = { format: :json, key: @author.api_key, issue_resource: {
        project_id: @project.id, issue_id: @issue.id, estimation: @hours,
        resource_id: @resource.id } }
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
    data = { id: @issue_resource.id, format: :json, key: @author.api_key,
      issue_resource: { issue_id: @issue.id, estimation: @new_estimation } }
    put :update, data
    assert_response :success
  end

  test 'DELETE #destroy as JSON' do
    create_test_setup
    @hours = 2
    create_existing_issue_resource_of @hours
    data =  { id: @issue_resource.id, format: :json, key: @author.api_key }
    delete :destroy, data
    assert_response :success
  end
end
