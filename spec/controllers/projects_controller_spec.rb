require 'spec_helper'

describe ProjectsController, type: :controller do
  include LoginSupport
  include SetupSupport
  render_views

  context 'GET #show' do
    context 'with module disabled' do
      before :example do
        login_as_admin
        create_base_setup_with_settings
        disable_plugin_for_project
        get :settings, id: @project.identifier
      end

      it 'runs successfully' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with module disabled' do
      it 'runs successfully' do
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
