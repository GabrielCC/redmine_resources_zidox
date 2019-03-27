class AddLoginToProjectResourceEmails < ActiveRecord::Migration[4.2]
  def up
    add_column :project_resource_emails, :login, :string, limit: 100
    sql = <<-SQL
      UPDATE
        project_resource_emails
      SET
        login = SUBSTRING_INDEX(email, '@', 1)
    SQL
    ActiveRecord::Base.connection.execute sql
    remove_column :project_resource_emails, :email
  end

  def down
    add_column :project_resource_emails, :email, :string
    sql = <<-SQL
      UPDATE
        project_resource_emails
      SET
        email = CONCAT(login, '@zitec.ro')
    SQL
    ActiveRecord::Base.connection.execute sql
    remove_column :project_resource_emails, :login
  end
end
