class IssueResourcesController < ApplicationController
  def create
    @issue_resource = IssueResource.new resource_params
    if @issue_resource.save
      @issue = @issue_resource.issue
      update_columns_for @issue
      add_journal_entry :create
      render partial: 'saved'
    else
      render partial: 'failed'
    end
  end

  def update
    @issue_resource = IssueResource.find params[:id]
    old_value = @issue_resource.estimation
    if @issue_resource.update_attributes resource_params
      @issue = @issue_resource.issue
      update_columns_for @issue
      add_journal_entry :update, old_value
      render partial: 'updated'
    else
      render partial: 'failed'
    end
  end

  def destroy
    @issue_resource = IssueResource.find params[:id]
    @issue = @issue_resource.issue
    @issue_resource.destroy
    update_columns_for @issue
    add_journal_entry :destroy
    render partial: 'saved'
  end

  private

  def resource_params
    params.require(:issue_resource).permit(:issue_id, :resource_id, :estimation)
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
