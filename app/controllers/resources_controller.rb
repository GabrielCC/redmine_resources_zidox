class ResourcesController < ApplicationController
  before_filter :set_divisions
  before_filter :set_division, only: [:create, :update]

  def create
    @resource = Resource.new params[:resource]
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
        if @resource.update_attributes params[:resource]
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
    setting_name = "plugin_redmine_resources_project_#{ @project.id }"
    setting_assign = setting_name + '='
    begin
      project_settings = Setting.send setting_name
    rescue NoMethodError
      Setting.define_setting setting_name, 'serialized' => true
      project_settings = Setting.send setting_name
    end
    Setting.send setting_assign, params[:settings]
    redirect_to settings_project_path @project, tab: 'resources'
  end

  private

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
