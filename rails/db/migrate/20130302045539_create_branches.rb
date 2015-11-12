class CreateBranches < ActiveRecord::Migration
  def change
    create_table :branches do |t|
      t.string :project_name
      t.string :branch_name
      t.string :repo_name
      t.date :date_created

      t.timestamps
    end
  end
end
