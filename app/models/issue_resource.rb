class IssueResource < ActiveRecord::Base
  unloadable
  belongs_to :issue
  belongs_to :resource
  validates_presence_of :issue_id, :resource_id, :estimation
  validates :estimation, numericality: { only_integer: true, greater_than: 0 }
  validates_uniqueness_of :issue_id, scope: :resource_id,
    message: ' only one estimation for resource'
  after_save :update_issue_timestamp_without_lock
  after_destroy :update_issue_timestamp_without_lock

  JOURNAL_DETAIL_PROPERTY = 'resource-estimation'

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

  def self.from_params(params)
    issue_resource = IssueResource.new
    issue_resource.issue_id = find_parent_feature_id_for params[:issue_id]
    issue_resource.resource_id = params[:resource_id]
    issue_resource.estimation = params[:estimation]
    issue_resource
  end

  def self.find_parent_feature_id_for(issue_id)
    return unless issue_id
    parent = Issue.where(id: issue_id).select([:id, :parent_id, :tracker_id]).first
    return parent.id if parent.tracker_id == 2
    find_parent_feature_id_for parent.parent_id
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
