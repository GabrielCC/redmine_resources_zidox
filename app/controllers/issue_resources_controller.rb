class IssueResourcesController < ApplicationController
  def create
    return unless authorized_to_create?
    @issue_resource = IssueResource.new resource_params
    if @issue_resource.save
      update_columns_for @issue
      add_journal_entry :create
      resources = @issue.project.resources_list @issue
      divisions = @issue.resources_with_divisions
      render json: { divisions: divisions, resources: resources }
    else
      render_errors
    end
  end

  def update
    return unless authorized_to_modify?
    old_value = @issue_resource.estimation
    if @issue_resource.update_attributes resource_params
      @issue = @issue_resource.issue
      update_columns_for @issue
      add_journal_entry :update, old_value
      render json: { success: 'Updated!' }
    else
      render_errors
    end
  end

  def destroy
    return unless authorized_to_modify?
    @issue_resource.destroy
    update_columns_for @issue
    add_journal_entry :destroy
    resources = @issue.project.resources_list @issue
    render json: resources
  end

  private

  def resource_params
    params.require(:issue_resource).permit(:issue_id, :resource_id, :estimation)
  end

  def render_not_found(entity)
    render json: { errors: "#{ entity.capitalize } not found!" }, status: 404
  end

  def render_forbidden
    render json: { errors: 'You are not alowed to do that!' }, status: 403
  end

  def render_errors
    render json: { errors: @issue_resource.errors.full_messages }, status: 400
  end

  def authorized_to_create?
    @issue = Issue.where(id: resource_params[:issue_id]).first
    render_not_found 'issue' and return unless @issue
    @project = @issue.project
    render_not_found 'project' and return unless @project
    unless User.current.can_edit_resources? @project
      render_forbidden and return
    end
    true
  end

  def authorized_to_modify?
    @issue_resource = IssueResource.where(id: params[:id]).first
    render_not_found 'issue resource' and return unless @issue_resource
    @issue = @issue_resource.issue
    render_not_found 'issue' and return unless @issue
    @project = @issue.project
    render_not_found 'project' and return unless @project
    unless User.current.can_edit_resources? @project
      render_forbidden and return
    end
    true
  end

  def update_columns_for(issue)
    unless issue.manually_added_resource_estimation
      issue.update_column :manually_added_resource_estimation, true
    end
  end

  def add_journal_entry(mode, old_value = nil)
    @issue = Issue.where(id: @issue_resource.issue_id).first or return
    journal = @issue.init_journal User.current, nil
    return unless journal
    journal.details << @issue_resource.journal_entry(mode, old_value)
    journal.save
  end
end
