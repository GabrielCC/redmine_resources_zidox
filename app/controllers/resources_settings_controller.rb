class ResourcesSettingsController < BaseController
  def index
    @settings = InstanceResourceSetting.all
  end

  def save
    InstanceResourceSetting.destroy_all
    params[:trackers] = {} if params[:trackers].nil?
    params[:roles] = {} if params[:roles].nil?
    map = {:visible => InstanceResourceSetting::VIEW_RESOURCES,
      :editable => InstanceResourceSetting::EDIT_RESOURCES
    }
    map.each_pair { |key, val|  
      create_resource_settings(key, val)
    }

    flash[:notice] = l(:notice_successful_update)
    redirect_to resources_settings_url
  end

  private
  def create_resource_settings(key, val)
    trackers = Tracker.find_all_by_id params[:trackers][key]
    roles = Role.find_all_by_id params[:roles][key]
    elements = trackers + roles
    elements.each { |element|
      settings = InstanceResourceSetting.new
      settings.setting_object = element
      settings.setting = val
      settings.save
    }
  end

end
