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

  private

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
