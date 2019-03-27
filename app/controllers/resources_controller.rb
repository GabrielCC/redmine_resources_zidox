class ResourcesController < ApplicationController
  before_action :set_divisions
  before_action :set_division, only: [:create, :update]

  def create
    @resource = Resource.new resources_params
    respond_to do |format|
      format.json do
        if @resource.save
          render json: @resource, status: :created, location: @resource
        else
          render json: @resource.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def update
    @resource = Resource.find params[:id]
    respond_to do |format|
      format.json do
        if @resource.update_attributes resources_params
          head :no_content
        else
          render json: @resource.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @resource = Resource.find params[:id]
    @resource.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def settings
    @project = Project.where(id: params[:project_id]).first
    render :not_found, status: 404 and return unless @project
    unless User.current.allowed_to?(:select_project_modules, @project)
      render :unauthorized, status: 401
    end
    setting_assign = "plugin_redmine_resources_project_#{ @project.id }="
    Setting.initialize_project_settings @project
    Setting.send setting_assign, params[:settings]
    redirect_to settings_project_path @project, tab: 'resources'
  end

  private

  def resources_params
    params.require(:resource).permit(:name, :code, :division_id)
  end

  def set_divisions
    @divisions = Division.select([:id, :name]).all.map do |division|
      [division.name, division.id]
    end
  end

  def set_division
    division = Division.where(id: params[:resource][:division_id]).first
    params[:resource][:division] = division if division
  end
end
