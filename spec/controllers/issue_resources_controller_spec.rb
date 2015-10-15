require 'spec_helper'

describe IssueResourcesController, type: :controller do
  include LoginSupport
  include SetupSupport
  render_views

  before :example do
    create_base_setup_with_settings
    create_project_membership
    login_as_author
    create_issue_without_initial_estimation
  end

  context 'POST #create as JSON' do
    it 'runs successfully' do
      @hours = 2
      data = { format: :json, key: @author.api_key, issue_resource: {
          project_id: @project.id, issue_id: @issue.id, estimation: @hours,
          resource_id: @resource.id } }
      post :create, data
      expect(response).to have_http_status(:ok)
    end

    it 'returns 400 when requesting twice with the same data' do
      @hours = 2
      data = { format: :json, key: @author.api_key, issue_resource: {
          project_id: @project.id, issue_id: @issue.id, estimation: @hours,
          resource_id: @resource.id } }
      post :create, data
      expect(response).to have_http_status(:ok)
      post :create, data
      expect(response).to have_http_status(:bad_request)
    end
  end

  context 'PUT #update as JSON' do
    it  'runs successfully' do
      @hours = 2
      create_existing_issue_resource_of @hours
      @new_estimation = 3
      data = { id: @issue_resource.id, format: :json, key: @author.api_key,
        issue_resource: { issue_id: @issue.id, estimation: @new_estimation } }
      put :update, data
      expect(response).to have_http_status(:ok)
    end
  end

  context 'DELETE #destroy as JSON' do
    it 'runs successfully' do
      @hours = 2
      create_existing_issue_resource_of @hours
      data =  { id: @issue_resource.id, format: :json, key: @author.api_key }
      delete :destroy, data
      expect(response).to have_http_status(:ok)
    end
  end
end
