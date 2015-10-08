require File.expand_path('../../test_helper', __FILE__)

class IssuesControllerTest < ActionController::TestCase
  def create_settings
    @hours = 2
    login_as_admin
    create_base_setup_with_settings
    create_issue_with_initial_estimation_of @hours
  end

  test 'GET #show' do
    create_settings
    get :show, id: @issue.id
    assert_response :success
    assert_select 'span', @custom_field.name
  end
end
