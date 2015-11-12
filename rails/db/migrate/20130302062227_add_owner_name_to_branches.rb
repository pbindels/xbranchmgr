class AddOwnerNameToBranches < ActiveRecord::Migration
  def change
    add_column :branches, :owner_name, :string
  end
end
