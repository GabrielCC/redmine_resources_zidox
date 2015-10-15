require 'spec_helper'

describe SettingsController, type: :controller do
  include LoginSupport
  include SetupSupport
  render_views

  context 'GET #settings for plugin' do
    context 'without initial settings' do
      before :example do
        login_as_admin
        create_base_setup_without_settings
      end

      it 'runs successfully' do
        expect_plugin_settings_page_to_load
      end
    end

    context 'with incomplete settings' do
      before :example do
        login_as_admin
        create_base_setup_without_trackers_for_custom_field
      end

      it 'runs successfully' do
        expect_plugin_settings_page_to_load
      end
    end

    context 'with incomplete settings' do
      before :example do
        login_as_admin
        create_base_setup_with_settings
      end

      it 'runs successfully' do
        expect_plugin_settings_page_to_load
      end
    end
  end
end
