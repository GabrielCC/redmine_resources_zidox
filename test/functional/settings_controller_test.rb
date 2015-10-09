require File.expand_path('../../test_helper', __FILE__)

class SettingsControllerTest < ActionController::TestCase
  def expect_plugin_settings_page_to_load
    get :plugin, id: 'redmine_resources'
    assert_response :success
    assert_select 'h2', text: /Redmine Resources/
    assert_select 'td', text: 'Default resource id:'
    assert_select 'td', text: 'Default custom field id:'
    assert_select 'h3', text: 'Visible for:'
    assert_select 'h3', text: 'Editable for:'
    assert_select 'select[name="settings[resource_id]"]'
    assert_select 'select[name="settings[custom_field_id]"]'
  end

  test 'GET plugin settings without initial settings' do
    login_as_admin
    create_base_setup_without_settings
    expect_plugin_settings_page_to_load
    assert_select 'h3',
      text: 'Select a custom field to attach resources to its trackers!'
  end

  test 'GET plugin settings with incomplete settings' do
    login_as_admin
    create_base_setup_without_trackers_for_custom_field
    expect_plugin_settings_page_to_load
    assert_select 'h3',
      text: 'No trackers configures for the selected custom field.'
    assert_select 'select[name="settings[resource_id]"] ' \
      'option[selected][value="' << @resource.id.to_s << '"]',
      text: @resource.name
    assert_select 'select[name="settings[custom_field_id]"] ' \
      'option[selected][value="' << @incomplete_custom_field.id.to_s << '"]',
      text: @incomplete_custom_field.name
  end

  test 'GET plugin settings with initial settings' do
    login_as_admin
    create_base_setup_with_settings
    expect_plugin_settings_page_to_load
    assert_select 'h3', text: 'Resources are avaliable for: ' \
      << @tracker.name.pluralize.capitalize
    assert_select 'select[name="settings[resource_id]"] ' \
      'option[selected][value="' << @resource.id.to_s << '"]',
      text: @resource.name
    assert_select 'select[name="settings[custom_field_id]"] ' \
      'option[selected][value="' << @custom_field.id.to_s << '"]',
      text: @custom_field.name
  end
end
