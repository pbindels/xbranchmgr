class AddDepEnvNameToBranches < ActiveRecord::Migration
  def change
    add_column :branches, :dep_env_name, :string
  end
end
