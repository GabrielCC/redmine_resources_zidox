class CreateProjectResources < ActiveRecord::Migration
  def change
  	unless ProjectResource.table_exists? 
	    create_table :project_resources do |t|
	      t.references :project
	      t.references :resource
	    end
	    add_index :project_resources, :project_id
	    add_index :project_resources, :resource_id
	end
  end
end
