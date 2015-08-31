class IssueResourcesController < ApplicationController
  def create
    @issue_resource = IssueResource.from_params params
    if @issue_resource.save
      @issue = @issue_resource.issue
      update_columns_for @issue
      add_journal_entry :create
      partial = 'issue_resources/saved'
    else
      partial = 'issue_resources/failed'
    end
    render partial: partial, layout: false,
      content_type: 'application/javascript'
  end

  def update
    @issue_resource = IssueResource.find params[:id]
    old_value = @issue_resource.estimation
    if @issue_resource.update_attributes params[:issue_resource]
      @issue = @issue_resource.issue
      update_columns_for @issue
      add_journal_entry :update, old_value
      partial = 'issue_resources/updated'
    else
      partial = 'issue_resources/failed'
    end
    render partial: partial, layout: false,
      content_type: 'application/javascript'
  end

  def destroy
    @issue_resource = IssueResource.find params[:id]
    @issue = @issue_resource.issue
    @issue_resource.destroy
    update_columns_for @issue
    add_journal_entry :destroy
    partial = 'issue_resources/saved'
    render partial: partial, layout: false,
      content_type: 'application/javascript'
  end

  private

  def update_columns_for(issue)
    unless issue.manually_added_resource_estimation
      issue.update_column :manually_added_resource_estimation, true
    end
    return if Issue.where(parent_id: issue.id).count > 0
    estimation = IssueResource.where(issue_id: issue.id).sum(:estimation)
    if issue.estimated_hours != estimation
      issue.update_column :estimated_hours, estimation
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
