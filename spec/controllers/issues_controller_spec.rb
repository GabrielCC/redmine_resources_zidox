require 'spec_helper'

describe IssuesController, type: :controller do
  include LoginSupport
  include SetupSupport
  render_views

  before :example do
    @hours = 2
    login_as_admin
    create_base_setup_with_settings
    create_issue_with_initial_estimation_of @hours
  end

  context 'GET #show' do
    it 'runs successfully' do
      get :show, id: @issue.id
      expect(response).to have_http_status(:ok)
    end
  end
end
