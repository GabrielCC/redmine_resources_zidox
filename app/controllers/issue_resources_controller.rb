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
      @issue_resource.save_journal :create
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
      @issue_resource.save_journal :update, old_value
      partial = 'issue_resources/updated'
    else
      partial = 'issue_resources/failed'
    end
    render partial: partial, layout: false, content_type: 'application/javascript'
  end

  def destroy
    @issue_resource = IssueResource.find params[:id]
    @issue_resource.destroy
    @issue_resource.save_journal :destroy
    partial = 'issue_resources/saved'
    render partial: partial, layout: false, content_type: 'application/javascript'
  end
end
