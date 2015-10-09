module SetupSupport
  private

  def build_issue_with(tracker, parent: nil, inital_estimation: nil)
    build :issue, tracker_id: tracker.id, priority_id: @priority.id,
      project_id: @project.id, author_id: @author.id,
      parent_id: parent ? parent.id : nil,
      custom_field_values: { @custom_field.id => inital_estimation }
  end

  def create_issue_with_initial_estimation_of(value)
    @issue = build_issue_with @tracker, inital_estimation: value
    @issue.save!
  end

  def create_issue_without_initial_estimation
    @issue = build_issue_with @tracker
    @issue.save!
  end

  def create_base_setup
    @custom_field = create :custom_field, :issue
    @author = create :user
    @division = create :division
    @resource = create :resource, division_id: @division.id
    @priority = create :issue_priority
    @status = create :issue_status
    @project = create :project
    @tracker = create :tracker, id: 2, default_status_id: @status.id
    create :custom_fields_tracker, custom_field_id: @custom_field.id,
      tracker_id: @tracker.id
    @project.trackers << @tracker
    @project.save!
    @project_resource = create :resource, division_id: @division.id
  end

  def create_base_setup_with_settings
    create_base_setup
    hash = ActiveSupport::HashWithIndifferentAccess.new(
      resource_id: @resource.id, custom_field_id: @custom_field.id)
    Setting.plugin_redmine_resources = hash
  end

  def create_base_setup_without_resource_id
    create_base_setup
    hash = ActiveSupport::HashWithIndifferentAccess.new(
      custom_field_id: @custom_field.id)
    Setting.plugin_redmine_resources = hash
  end

  def create_base_setup_without_custom_field
    create_base_setup
    hash = ActiveSupport::HashWithIndifferentAccess.new(
      resource_id: @resource.id)
    Setting.plugin_redmine_resources = hash
  end

  def create_base_setup_without_trackers_for_custom_field
    create_base_setup
    @incomplete_custom_field = create :custom_field, :issue
    hash = ActiveSupport::HashWithIndifferentAccess.new(
      resource_id: @resource.id, custom_field_id: @incomplete_custom_field.id)
    Setting.plugin_redmine_resources = hash
  end

  def create_base_setup_without_settings
    create_base_setup
    Setting.plugin_redmine_resources = \
      ActiveSupport::HashWithIndifferentAccess.new
  end

  def enable_plugin_for_project
    @project.enabled_module_names = @project.enabled_module_names \
      << 'redmine_resources'
  end

  def disable_plugin_for_project
    @project.enabled_module_names = @project.enabled_module_names \
      - ['redmine_resources']
  end

  def create_project_resource_settings
    setting_name = "plugin_redmine_resources_project_#{ @project.id }"
    setting_assign = setting_name + '='
    begin
      project_settings = Setting.send setting_name
    rescue NoMethodError
      Setting.define_setting setting_name, 'serialized' => true
      project_settings = Setting.send setting_name
    end
    Setting.send setting_assign, { "custom" => "1",
      "resource_id" => @project_resource.id.to_s }
  end
end
