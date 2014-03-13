class HookListener < Redmine::Hook::ViewListener
  def view_projects_settings_members_table_header(context = {} )
    return content_tag("th", "Resource Label") if context[:project].module_enabled?("redmine_resources")
  end
  render_on :view_projects_settings_members_table_row, :partial => 'resources/member'
  render_on :view_projects_settings_add_members, :partial => 'resources/add_membership'
  render_on :view_issues_show_description_bottom, :partial => 'resources/issue'
  render_on :view_issues_sidebar_queries_bottom, :partial => 'resources/left_column'

end