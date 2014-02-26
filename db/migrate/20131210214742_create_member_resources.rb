class CreateMemberResources < ActiveRecord::Migration
  def change
    create_table :member_resources do |t|

      t.references :member

      t.references :resource


    end

    add_index :member_resources, :member_id

    add_index :member_resources, :resource_id

  end
end
