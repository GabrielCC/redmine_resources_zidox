class IssueResource < ActiveRecord::Base
  unloadable
  belongs_to :issue
  belongs_to :resource
  validates_presence_of :issue_id, :resource_id, :estimation
  validates :estimation, numericality: { only_integer: true }
  validates_uniqueness_of :issue_id, scope: :resource_id,
    message: ' only one estimation for resource'
  after_save :update_issue_timestamp_without_lock
  after_destroy :update_issue_timestamp_without_lock

  JOURNAL_DETAIL_PROPERTY = 'resource-estimation'

  def self.from_params(params)
    issue_resource = IssueResource.new
    project = Project.exists? id: params[:project_id]
    issue = Issue.where(id: params[:issue_id]).first
    if project && issue
      resource = Resource.where(id: params[:resource_id]).first || Resource.new
      issue_resource.issue = issue
      issue_resource.resource = resource
      issue_resource.estimation = params[:estimation]
    end
    issue_resource
  end

  def to_json
    {
      estimation: estimation,
      code: resource.code
    }
  end

  def journal_entry(operation, old_value = nil)
    JournalDetail.new(
      property: IssueResource::JOURNAL_DETAIL_PROPERTY,
      prop_key: id,
      old_value: '',
      value: journal_note(operation, old_value)
    )
  end

  private

  def journal_note(operation, old_value = nil)
    @messages ||= {
      create: " created #{resource.code} #{estimation}h",
      update: " changed from #{resource.code} #{old_value}h to #{resource.code} #{estimation}h",
      destroy: " deleted #{resource.code} #{estimation}h"
    }
    @messages[operation]
  end


  def update_issue_timestamp_without_lock
    issue.update_column :updated_on, Time.now
  end
end
