class IssueResource < ActiveRecord::Base
  unloadable
  belongs_to :issue
  belongs_to :resource
  validates_presence_of :issue_id, :resource_id, :estimation
  validates :estimation, numericality: { only_integer: true }
  validates_uniqueness_of :issue_id, :scope => :resource_id, :message => ' only one estimation for resource'

  def self.from_params(params)
    issue_resource = IssueResource.new
    project = Project.find params[:project_id]
    issue = Issue.find params[:issue_id]
    begin
      resource = Resource.find params[:resource_id]  
    rescue Exception => e
      resource = Resource.new
    end
    if resource.code.nil? || resource.code != params[:resource]
      resource = Resource.find_by_code params[:resource]
    end
        
    unless project.nil? || issue.nil?
      issue_resource.issue = issue
      issue_resource.resource = resource
      issue_resource.estimation = params[:estimation]
    end
    issue_resource
  end

  def to_json
    hash = {}
    hash[:estimation] = self.estimation
    hash[:code] = self.resource.code
    hash
  end
end
