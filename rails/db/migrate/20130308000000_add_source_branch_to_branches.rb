class AddSourceBranchToBranches < ActiveRecord::Migration
  def change
    add_column :branches, :source_branch, :string
  end
end