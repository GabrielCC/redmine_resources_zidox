class ProjectResourcesController < BaseController
  # GET /project/:project_id/resources
  # GET /project/:project_id/resources.json
  accept_api_auth :index, :create
  def index
    @project_resources = ProjectResource.includes(:resource).find_all_by_project_id(params[:project_id])
    @resources = []
    @project_resources.each { |pr|
      @resources << pr.resource  
    }
    respond_to do |format|
      format.html # index.html.erb
      format.api #index.api.rsb
    end
  end


  # POST /resources
  # POST /resources.json
  def create
    resources = params[:resources]
    status = false
    errors = []
    ActiveRecord::Base.transaction do
      ProjectResource.where(:project_id => params[:project_id]).delete_all
      resources.each { |resource|
        begin
          resource_entry = Resource.find_or_create_by_params(resource)
          pr = ProjectResource.new
          pr.resource = resource_entry
          pr.project_id = params[:project_id]
          pr.save   
        rescue Exception => e
          errors << {:message => e.message, :resource => resource}  
        end 
      }
      if errors.count == 0 
        status = true
      else
      end
    end
    respond_to do |format|
      if status
        format.json { render json: {:message => 'Resources saved successfully'}, status: :created, location: @resource }
      else
        format.json { render json: errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /resources/1
  # PUT /resources/1.json
  def update
    @resource = Resource.find(params[:id])

    respond_to do |format|
      if @resource.update_attributes(params[:resource])
        format.html { redirect_to @resource, notice: 'Resource was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resources/1
  # DELETE /resources/1.json
  def destroy
    @resource = Resource.find(params[:id])
    @resource.destroy

    respond_to do |format|
      format.html { redirect_to resources_url }
      format.json { head :no_content }
    end
  end

  def set_departments
    @departments = Department.all
    @departments.map! { |e| 
      [e.name, e.id.to_i]  
    }
  end

  def trackers
    ResourceSetting.destroy_all(:project_id => @project.id)
    params[:trackers] = {} if params[:trackers].nil?
    params[:roles] = {} if params[:roles].nil?
    map = {:visible => ResourceSetting::VIEW_RESOURCES,
      :editable => ResourceSetting::EDIT_RESOURCES
    }
    map.each_pair { |key, val|  
      create_resource_settings(key, val)
    }
    flash[:notice] = l(:notice_successful_update)
    redirect_to_settings_project
  end

  def workflows
    ResourcesWorkflow.destroy_all( ["project_id=?",params[:project_id]])
      (params[:issue_status] || []).each { |status_id, transitions|
        transitions.each { |new_status_id, options|
          ResourcesWorkflow.create(:project_id => params[:project_id], :old_status_id => status_id, :new_status_id => new_status_id)
        }
      }

    flash[:notice] = l(:notice_successful_update)
    redirect_to_settings_project('resources_workflows')
  end

  private
  def create_resource_settings(key, val)
    trackers = Tracker.find_all_by_id params[:trackers][key]
    roles = Role.find_all_by_id params[:roles][key]
    elements = trackers + roles
    elements.each { |element|
      settings = ResourceSetting.new
      settings.setting_object = element
      settings.project = @project
      settings.setting = val
      settings.save
    }
  end



  def redirect_to_settings_project(tab = 'resources')
    redirect_to settings_project_path(@project, :tab => tab) and return
  end
  
  def set_department
    department = Department.find(params[:resource][:department_id])
    if !department.nil?
      params[:resource][:department] = department
    end
  end

end
