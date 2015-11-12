class AddDoDeployToBranches < ActiveRecord::Migration
  def change
        add_column :branches, :do_deploy, :boolean
  end
end
