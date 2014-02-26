module ApplicationHelperPatch       
    def self.included(base)
        # base.send(:include, InstanceMethods)
        base.class_eval do
          # 
          # Anything you type in here is just like typing directly in the core
          # source files and will be run when the controller class is loaded.
          # 
            # Return true if user is authorized for controller/action, otherwise false
		  def authorize_globally_for(controller, action)
		    User.current.allowed_to_globally?({:controller => controller, :action => action}, {})
		  end

        end
    end
end # module patch