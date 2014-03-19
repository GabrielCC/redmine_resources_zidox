class IssueResource < ActiveRecord::Base
  unloadable
  belongs_to :issue
  belongs_to :resource
  validates_presence_of :issue_id, :resource_id, :estimation
  validates :estimation, numericality: { only_integer: true }
  validates_uniqueness_of :issue_id, :scope => :resource_id, :message => ' only one estimation for resource'

  after_create 'save_journal(:created)'
  after_destroy 'save_journal(:deleted)'
  after_update 'save_journal(:updated)'

  def self.from_params(params)
    issue_resource = IssueResource.new
    project = Project.find params[:project_id]
    issue = Issue.find params[:issue_id]
    begin
      resource = Resource.find params[:resource_id]  
    rescue Exception => e
      resource = Resource.new
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

  private

  def journal_note(operation)
    messages = {
      :created => "*Estimation* created #{resource.code} #{estimation}h",
      :updated => "*Estimation* changed from #{resource.code} #{estimation_was}h to #{resource.code} #{estimation}h",
      :deleted => "*Estimation* deleted #{resource.code} #{estimation}h"
    }
    messages[operation]
  end

  def save_journal(operation)
    journal = issue.init_journal(User.current, journal_note(operation))
    journal.save
  end
end
