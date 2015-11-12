class AddHudsonJobToBranches < ActiveRecord::Migration
  def change
    add_column :branches, :hudson_job, :boolean
  end
end
