require_dependency 'project'
module RedmineResources
  module Patches
# Patches Redmine's Project dynamically.  Adds a relationship
# Project +has_many+ to Resource
module ProjectPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      has_many :project_resource, dependent: :destroy
      has_many :resource, :through => :project_resource
    end

  end

  module ClassMethods
  end

  module InstanceMethods
  end
end
  end
end


  unless Project.included_modules.include? RedmineResources::Patches::ProjectPatch
    Project.send(:include, RedmineResources::Patches::ProjectPatch)
  end