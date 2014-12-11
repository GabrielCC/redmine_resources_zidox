class ResourcesController < BaseController
  before_filter :set_departments
  before_filter :find_project_by_project_id, :only => [:trackers, :workflows]
  before_filter :set_department, :only => [:update,:create]
  # GET /resources
  # GET /resources.json
  def index
    @resources = Resource.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @resources }
    end
  end

  # GET /resources/1
  # GET /resources/1.json
  def show
    @resource = Resource.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @resource }
    end
  end

  # GET /resources/new
  # GET /resources/new.json
  def new
    @resource = Resource.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @resource }
    end
  end

  # GET /resources/1/edit
  def edit
    @resource = Resource.find(params[:id])
    
  end

  # POST /resources
  # POST /resources.json
  def create
    @resource = Resource.new(params[:resource])
    respond_to do |format|
      if @resource.save
        format.html { redirect_to @resource, notice: 'Resource was successfully created.' }
        format.json { render json: @resource, status: :created, location: @resource }
      else
        format.html { render action: "new" }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
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
    if ResourceSetting.project_tracker_editable(@project.id)
      ResourceSetting.destroy_all(:project_id => @project.id)
      params[:trackers] = {} if params[:trackers].nil?
      params[:roles] = {} if params[:roles].nil?
      map = {:visible => ResourceSetting::VIEW_RESOURCES,
        :editable => ResourceSetting::EDIT_RESOURCES
      }
      map.each_pair { |key, val|  
        create_resource_settings(key, val)
      }
    end

    if params[:project_specific_resource_workflow]
      ResourceSetting.activate_project_workflow_editable(@project.id)
    end
    if params[:project_specific_resource_tracker]
      ResourceSetting.activate_project_tracker_editable(@project.id)
    end

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
