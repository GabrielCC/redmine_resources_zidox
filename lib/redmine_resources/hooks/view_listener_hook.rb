class ViewListenerHook < Redmine::Hook::ViewListener
  render_on :view_issues_sidebar_top, partial: 'resources/issue'
end
