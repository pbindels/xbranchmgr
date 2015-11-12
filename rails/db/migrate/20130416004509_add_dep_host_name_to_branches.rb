class AddDepHostNameToBranches < ActiveRecord::Migration
  def change
       add_column :branches, :dep_host_name, :string
  end
end
