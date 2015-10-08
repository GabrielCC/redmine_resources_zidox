require File.expand_path('../../test_helper', __FILE__)

class SettingsControllerTest < ActionController::TestCase
  def expect_plugin_settings_page_to_load
    get :plugin, id: 'redmine_resources'
    assert_response :success
    assert_select 'h2', text: /Redmine Resources/
    assert_select 'td', text: 'Default resource id:'
    assert_select 'td', text: 'Default custom field id:'
    assert_select 'select[name="settings[resource_id]"]'
    assert_select 'select[name="settings[custom_field_id]"]'
  end

  test 'GET plugin settings without initial settings' do
    login_as_admin
    create_base_setup_without_settings
    expect_plugin_settings_page_to_load
  end

  test 'GET plugin settings with initial settings' do
    login_as_admin
    create_base_setup_with_settings
    expect_plugin_settings_page_to_load
    assert_select 'select[name="settings[resource_id]"] ' \
      'option[selected][value="' << @resource.id.to_s << '"]',
      text: @resource.name
    assert_select 'select[name="settings[custom_field_id]"] ' \
      'option[selected][value="' << @custom_field.id.to_s << '"]',
      text: @custom_field.name
  end
end
