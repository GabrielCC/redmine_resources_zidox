require File.expand_path('../../test_helper', __FILE__)

class ProjectsControllerTest < ActionController::TestCase
  def expect_project_resource_settings_page_to_load
    get :settings, id: @project.identifier, tab: 'resources'
    assert_response :success
    assert_select 'a#tab-resources', text: 'Resources'
    assert_select 'td', text: 'Use project specific settings:'
    assert_select 'td', text: 'Resource for initial estimation:'
    assert_select 'h3', text: 'Visible for:'
    assert_select 'h3', text: 'Editable for:'
    assert_select 'input[type="checkbox"][name="settings[custom]"]'
    assert_select 'select[name="settings[resource_id]"]'
  end

  test 'routes /resources/settings to #settings' do
    assert_routing({ method: :post, path: '/resources/settings' },
      { controller: 'resources', action: 'settings' })
  end

  test 'GET project settings with module disabled' do
    login_as_admin
    create_base_setup_with_settings
    disable_plugin_for_project
    get :settings, id: @project.identifier
    assert_response :success
    assert_select 'a#tab-resources', false
  end

  test 'GET project settings without initial settings' do
    login_as_admin
    create_base_setup_without_settings
    enable_plugin_for_project
    expect_project_resource_settings_page_to_load
    assert_select 'h3',
      text: 'No custom field selected for resource estimation!'
  end

  test 'GET project settings with incomplete settings' do
    login_as_admin
    create_base_setup_without_trackers_for_custom_field
    enable_plugin_for_project
    expect_project_resource_settings_page_to_load
    assert_select 'h3',
      text: 'No trackers configures for resource estimation!'
  end

  test 'GET project settings with initial settings' do
    login_as_admin
    create_base_setup_with_settings
    enable_plugin_for_project
    expect_project_resource_settings_page_to_load
    assert_select 'h3', text: 'Resources are avaliable for: ' \
      << @tracker.name.pluralize.capitalize
  end

  test 'GET project settings without custom settings' do
    login_as_admin
    create_base_setup_with_settings
    enable_plugin_for_project
    expect_project_resource_settings_page_to_load
    assert_select 'input#settings_custom[checked=checked]', false
    assert_select 'select#settings_resource_id option[selected]', false
  end

  test 'GET project settings with custom settings' do
    login_as_admin
    create_base_setup_with_settings
    enable_plugin_for_project
    create_project_resource_settings
    expect_project_resource_settings_page_to_load
    assert_select 'input#settings_custom[checked=checked]'
    assert_select 'select#settings_resource_id option[selected]',
      text: @project_resource.name
  end
end
