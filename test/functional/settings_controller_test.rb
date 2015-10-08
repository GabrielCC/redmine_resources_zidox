require File.expand_path('../../test_helper', __FILE__)

class SettingsControllerTest < ActionController::TestCase
  def create_settings
    login_as_admin
    create_base_setup_without_settings
  end

  test 'GET plugin settings' do
    create_settings
    get :plugin, id: 'redmine_resources'
    assert_response :success
    assert_select 'h2', /Redmine Resources/
  end
end
