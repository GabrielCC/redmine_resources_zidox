class ProjectResourceEmail < ActiveRecord::Base
  belongs_to :project
  belongs_to :resource
end
