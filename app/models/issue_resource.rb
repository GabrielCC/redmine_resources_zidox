class IssueResource < ActiveRecord::Base
  unloadable
  belongs_to :issue
  belongs_to :resource

  def self.from_params(params)
    issue_resource = IssueResource.new
    project = Project.find params[:project_id]
    issue = Issue.find params[:issue_id]
    resource = Resource.find params[:resource_id]
    unless project.nil? || issue.nil?
      issue_resource.issue = issue
      issue_resource.resource = resource
      issue_resource.estimation = params[:estimation]
    end
    issue_resource
  end
end
