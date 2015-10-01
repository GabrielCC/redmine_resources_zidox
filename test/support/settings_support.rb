module SettingsSupport
  private

  def build_issue_with(tracker, parent: nil, estimated_hours: nil)
    issue = build(:issue)
    issue.tracker = tracker
    issue.priority = @priority
    issue.project = @project
    issue.author = @author
    issue.parent = parent
    issue.estimated_hours = estimated_hours
    issue
  end

  def create_base_setup
    @author = create :user
    @division = create :division
    @resource = create :resource, division_id: @division.id
    @priority = create :issue_priority
    @status_new = create :issue_status, id: 1, name: 'New'
    @status_killed = create :issue_status, id: 6, name: 'Killed'
    @status_not_a_problem = create :issue_status, id: 23, name: 'Not a problem'
    @project = create :project
    @root_tracker = create :tracker, id: 2, default_status_id: @status_new.id,
      name: 'Feature'
    @child_tracker = create :tracker, id: 4, default_status_id: @status_new.id,
      name: 'Task'
    @resource_setting = create resource_setting project_id: @project_id,
      setting_object_id: @root_tracker
    @project_resource_email = create :project_resource_email,
      project_id: @project.id, resource_id: @resource.id, login: @user.login
    @project.trackers << [@root_tracker, @child_tracker]
    @project.save!
  end
end
