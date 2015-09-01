class ProjectResourcesController < BaseController
  accept_api_auth :index, :create

  def index
    @project_resources = ProjectResource.includes(:resource)
      .where(project_id: params[:project_id]).all
    @resources = @project_resources.reduce([]) do |total, project_resource|
      total << project_resource.resource
    end
    respond_to do |format|
      format.html
      format.api
    end
  end

  def create
    resources = params[:resources]
    errors = []
    begin
      project = Project.find params[:project_id]
    rescue StandardError => error
      errors << { message: error.message, resource: {} }
    end
    if errors.count == 0
      ActiveRecord::Base.transaction do
        clean_resource_associations
        resources.each do |resource|
          resource_status = process_resource(resource, project)
          if resource_status != true
            errors << { message: resource_status, resource: resource }
          end
        end
        if errors.count != 0
          raise ActiveRecord::Rollback
        end
      end
    end
    respond_to do |format|
      if errors.count == 0
        format.json do
          render json: { message: 'Resources saved successfully' },
            status: :created, location: @resource
        end
      else
        format.json { render json: errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @resource = Resource.find params[:id]
    respond_to do |format|
      if @resource.update_attributes(params[:resource])
        format.html do
          redirect_to @resource, notice: 'Resource was successfully updated.'
        end
        format.json { head :no_content }
      else
        format.html { render action: :edit }
        format.json do
          render json: @resource.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @resource = Resource.find params[:id]
    @resource.destroy
    respond_to do |format|
      format.html { redirect_to resources_url }
      format.json { head :no_content }
    end
  end

  def set_divisions
    @divisions = Division.select([:id, :name]).all.map do |division|
      [division.name, division.id]
    end
  end

  def trackers
    ResourceSetting.destroy_all project_id: @project.id
    params[:trackers] = {} if params[:trackers].nil?
    params[:roles] = {} if params[:roles].nil?
    map = { visible: ResourceSetting::VIEW_RESOURCES,
      editable: ResourceSetting::EDIT_RESOURCES
    }
    map.each_pair {|key, val| create_resource_settings key, val }
    flash[:notice] = l :notice_successful_update
    redirect_to_settings_project
  end

  private

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

  def clean_resource_associations
    [ProjectResource, ProjectResourceEmail].each do |model|
      model.where(project_id: params[:project_id]).delete_all
    end
  end

  def process_resource(resource, project)
    begin
      resource_entry = Resource.find_or_create_by_params(resource)
      pr = ProjectResource.new
      pr.resource = resource_entry
      pr.project_id = params[:project_id]
      pr.save
      if resource[:users].nil?
         return 'Users array not provided';
      else
        resource[:users].each do |email|
          pre = ProjectResourceEmail.new
          pre.project = project
          pre.resource = resource_entry
          pre.email = email
          pre.save
        end
        return true
      end
    rescue StandardError => error
      return error.message
    end
  end
end
