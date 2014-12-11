class ResourcesWorkflowsController < BaseController
  layout "base"
  def index
  end

  def save
    InstanceResourcesWorkflow.destroy_all
      (params[:issue_status] || []).each { |status_id, transitions|
        transitions.each { |new_status_id, options|
          InstanceResourcesWorkflow.create(:old_status_id => status_id, :new_status_id => new_status_id)
        }
      }

    flash[:notice] = l(:notice_successful_update)
    redirect_to resources_workflows_url
  end

end
