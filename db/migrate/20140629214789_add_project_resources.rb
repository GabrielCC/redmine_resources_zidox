class AddProjectResources < ActiveRecord::Migration
  def change
    MemberResource.all.each {|mr|
      pr = ProjectResource.new
      pr.project = mr.member.project
      pr.resource = mr.resource
      pr.save
    }
  end
end
