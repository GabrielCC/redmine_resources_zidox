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
    @author = create :user
    @division = create :division
    @resource = create :resource, division_id: @division.id
    @priority = create :issue_priority
    @status = create :issue_status
    @project = create :project
    @tracker = create :tracker, default_status_id: @status.id
    @role = create :role, :manager
    @custom_field = create :custom_field, :issue
    create :custom_fields_tracker, custom_field_id: @custom_field.id,
      tracker_id: @tracker.id
    create :custom_fields_role, custom_field_id: @custom_field.id,
      role_id: @role.id
    @project.trackers << @tracker
    @project.save!
    @project_resource = create :resource, division_id: @division.id
  end

  def create_project_membership
    @member = create :member, user_id: @author.id, project_id: @project.id,
      role_ids: [@role.id]
    @member_role = create :member_role, member_id: @member.id, role_id: @role.id
  end

  def expect_issue_to_have_a_resources_of(value)
    @found_resources = @issue.issue_resources.all
    expect(@found_resources).not_to be_empty
    expect(@found_resources.size).to eq(1)
    @found_resource = @found_resources[0]
    expect(@found_resource).to be_an_instance_of(IssueResource)
    expect(@found_resource.estimation).to eq(value)
  end

  def expect_issue_to_have_no_resources
    expect(@issue.issue_resources.all).to be_empty
  end

  def expect_issue_to_have_an_initial_estimation_of(value)
    custom_field = @issue.custom_values
      .where(custom_field_id: @custom_field.id).first
    custom_value = custom_field.value
    expect(custom_value).to eq(value.to_s)
  end

  def expect_issue_with_initial_estimation_to_create_resource
    hours = 2
    create_issue_with_initial_estimation_of hours
    expect_issue_to_have_a_resources_of hours
    expect_issue_to_have_an_initial_estimation_of hours
  end

  def expect_issue_to_have_no_initial_estimation
    custom_field = @issue.custom_values
      .where(custom_field_id: @custom_field.id).first
    custom_value = custom_field.value
    expect(custom_value.to_i).to eq(0)
  end

  def create_base_setup_with_settings
    create_base_setup
    hash = ActiveSupport::HashWithIndifferentAccess.new(
      resource_id: @resource.id, custom_field_id: @custom_field.id,
      visible: { @role.id.to_s => '1' }, editable: { @role.id.to_s => '1' })
    Setting.plugin_redmine_zidox = hash
  end

  def create_base_setup_without_resource_id
    create_base_setup
    hash = ActiveSupport::HashWithIndifferentAccess.new(
      custom_field_id: @custom_field.id)
    Setting.plugin_redmine_zidox = hash
  end

  def create_base_setup_without_custom_field
    create_base_setup
    hash = ActiveSupport::HashWithIndifferentAccess.new(
      resource_id: @resource.id)
    Setting.plugin_redmine_zidox = hash
  end

  def create_base_setup_without_trackers_for_custom_field
    create_base_setup
    @incomplete_custom_field = create :custom_field, :issue
    hash = ActiveSupport::HashWithIndifferentAccess.new(
      resource_id: @resource.id, custom_field_id: @incomplete_custom_field.id)
    Setting.plugin_redmine_zidox = hash
  end

  def create_existing_issue_resource_of(value)
    @issue_resource = create :issue_resource, issue_id: @issue.id,
      resource_id: @resource.id, estimation: @hours
  end

  def create_base_setup_without_settings
    create_base_setup
    Setting.plugin_redmine_zidox = \
      ActiveSupport::HashWithIndifferentAccess.new
  end

  def enable_plugin_for_project
    @project.enabled_module_names = @project.enabled_module_names \
      << 'redmine_zidox'
  end

  def disable_plugin_for_project
    @project.enabled_module_names = @project.enabled_module_names \
      - ['redmine_zidox']
  end

  def create_project_resource_settings
    Setting.initialize_project_settings @project
    setting_assign = "plugin_redmine_zidox_project_#{ @project.id }="
    Setting.send setting_assign, { "custom" => "1",
      "resource_id" => @project_resource.id.to_s }
  end

  def create_workflow_permission_with_rule(value)
    @permission = create :workflow_permission, tracker_id: @tracker.id,
      role_id: @role.id, old_status_id: @status.id,
      field_name: @custom_field.id.to_s, rule: value
  end

  def make_the_custom_field_read_only
    create_workflow_permission_with_rule 'readonly'
  end

  def make_the_custom_field_required
    create_workflow_permission_with_rule 'required'
  end

  def remove_the_custom_field_workflow_permission
    @permission.destroy if @permission
  end

  def expect_project_resource_settings_page_to_load
    get :settings, id: @project.identifier, tab: 'resources'
    expect(response).to have_http_status(:ok)
  end

  def expect_plugin_settings_page_to_load
    get :plugin, id: 'redmine_zidox'
    expect(response).to have_http_status(:ok)
  end
end
