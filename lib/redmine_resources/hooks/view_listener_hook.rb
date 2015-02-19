class ViewListenerHook < Redmine::Hook::ViewListener
  render_on :view_issues_before_sidebar, partial: 'resources/issue'
end
