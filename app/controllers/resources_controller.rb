class ResourcesController < ApplicationController
  before_filter :set_divisions
  before_filter :find_project_by_project_id, only: :trackers
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

  def trackers
    ResourceSetting.destroy_all project_id: @project.id
    params[:trackers] = {} if params[:trackers].nil?
    params[:roles] = {} if params[:roles].nil?
    map = { visible: ResourceSetting::VIEW_RESOURCES,
      editable: ResourceSetting::EDIT_RESOURCES }
    map.each_pair {|key, val| create_resource_settings key, val }
    flash[:notice] = l(:notice_successful_update)
    redirect_to_settings_project
  end

  private

  def set_divisions
    @divisions = Division.select([:id, :name]).all.map do |division|
      [division.name, division.id]
    end
  end

  def create_resource_settings(key, val)
    trackers = Tracker.where(id: params[:trackers][key]).all
    roles = Role.where(id: params[:roles][key]).all
    elements = trackers + roles
    elements.each do |element|
      settings = ResourceSetting.new
      settings.setting_object = element
      settings.project = @project
      settings.setting = val
      settings.save
    end
  end

  def redirect_to_settings_project(tab = 'resources')
    redirect_to settings_project_path(@project, tab: tab) and return
  end

  def set_division
    division = Division.where(id: params[:resource][:division_id]).first
    params[:resource][:division] = division if division
  end
end
