class AddProjectResources < ActiveRecord::Migration
  def change
    MemberResource.all.each {|mr|
      if !mr.member.nil? && !mr.resource.nil?
        pr = ProjectResource.new
        pr.project = mr.member.project
        pr.resource = mr.resource
        pr.save
      end
    }
  end
end
