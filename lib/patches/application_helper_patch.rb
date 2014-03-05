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

          def resources_visible(issue, project)
            roles = User.current.roles_for_project(project)
            trackers = issue.tracker

            visible = false;
            roles.each { |role|
              if !visible 
                visible = role.has_resources
              end 
            }
            visible && trackers.has_resources
          end

          def resources_for_project(project)
            members = project.members
            resources = []
            members.each { |member|
              resource = member.resource
              resources[resource.id] = resource
            }
            resources
          end
        end
    end
end # module patch