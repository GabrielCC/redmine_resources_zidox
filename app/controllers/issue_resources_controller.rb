class IssueResourcesController < BaseController

  def index
    @issue_resources = IssueResource.all
    respond_to do |format|
      format.html
      format.json { render json: @issue_resources }
    end
  end

  def show
    @issue_resource = IssueResource.find params[:id]
    respond_to do |format|
      format.html
      format.json { render json: @issue_resource }
    end
  end

  def new
    @issue_resource = IssueResource.new
    respond_to do |format|
      format.html
      format.json { render json: @issue_resource }
    end
  end

  def edit
    @issue_resource = IssueResource.find params[:id]
  end

  def create
    @issue_resource = IssueResource.from_params params
    if @issue_resource.save
      update_issue_estimation :create
      partial = 'issue_resources/saved'
    else
      partial = 'issue_resources/failed'
    end
    render partial: partial, layout: false, content_type: 'application/javascript'
  end

  def update
    @issue_resource = IssueResource.find params[:id]
    old_value = @issue_resource.estimation
    if @issue_resource.update_attributes params[:issue_resource]
      update_issue_estimation :update, old_value
      partial = 'issue_resources/updated'
    else
      partial = 'issue_resources/failed'
    end
    render partial: partial, layout: false, content_type: 'application/javascript'
  end

  def destroy
    @issue_resource = IssueResource.find params[:id]
    @issue_resource.destroy
    update_issue_estimation :destroy
    partial = 'issue_resources/saved'
    render partial: partial, layout: false, content_type: 'application/javascript'
  end

  private

  def update_issue_estimation(mode, old_value = nil)
    @issue = Issue.where(id: @issue_resource.issue_id).first
    @old_value = @issue.estimated_hours
    @new_value = @issue.find_total_estimated_hours
    @issue.update_column(:estimated_hours, @new_value)
    journal = @issue.init_journal User.current, nil
    return unless journal
    journal.details << @issue_resource.journal_entry(mode, old_value)
    journal.details << estimation_change_journal_entry
    journal.save
  end

  def estimation_change_journal_entry
    JournalDetail.new(
      property: "attr",
      prop_key: "estimated_hours",
      old_value: @old_value,
      value: @new_value
    )
  end
end
