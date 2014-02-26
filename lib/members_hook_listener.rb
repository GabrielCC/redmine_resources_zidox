class MembersHookListener < Redmine::Hook::ViewListener
  def view_projects_settings_members_table_header(context={} )
    return content_tag("th", "Resource")
  end
  render_on :view_projects_settings_members_table_row, :partial => 'resources/member'
  render_on :view_projects_settings_add_members, :partial => 'resources/add_membership'
  
end