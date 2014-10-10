class CreateProjectResourceEmails < ActiveRecord::Migration
  def change
  	unless ProjectResourceEmail.table_exists? 
	    create_table :project_resource_emails do |t|
	      t.references :project
	      t.references :resource
        t.string :email
	    end
	    add_index :project_resource_emails, :project_id
	    add_index :project_resource_emails, :resource_id
	  end
  end
end
