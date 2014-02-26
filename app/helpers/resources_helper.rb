module ResourcesHelper
  # Return true if user is authorized for controller/action, otherwise false
  def authorize_globally_for(controller, action)
    User.current.allowed_to_globally?({:controller => controller, :action => action}, @project, true)
  end
end
