# To be removed after the data was transfered to Setting
class ResourceSetting < ActiveRecord::Base
  unloadable
  belongs_to :project
  VIEW_RESOURCES = 1
  EDIT_RESOURCES = 2
end
