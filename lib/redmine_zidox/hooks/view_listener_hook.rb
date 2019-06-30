class ViewListenerHook < Redmine::Hook::ViewListener
  def view_issues_sidebar_top(context)
    controller, issue = context[:controller], context[:issue]
    return '' unless issue
    controller.render_to_string partial: 'resources/issue', locals: context
  end

  def view_layouts_base_html_head(context)
    project, controller = context[:project], context[:controller]
    return '' unless controller.is_a? IssuesController
    controller.render_to_string partial: 'redmine_zidox/header_assets'
  end
end
