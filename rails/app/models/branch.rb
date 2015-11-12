class Branch < ActiveRecord::Base
  attr_accessible :branch_name, :date_created, :project_name, :repo_name, :owner_name, :source_branch, :ab, :hudson_job, :dep_host_name, :dep_env_name, :do_deploy
  @@all_branches_exist = true

  #projects = APP_CONFIG['projects']
  #products = APP_CONFIG['products']
   
  validates_format_of :branch_name,   :without => /[-]/ , :message => ": Hyphens not allowed!"

  projects = Rails.configuration.my_scope.projects
 
  #validate :branches_exist

  def branches_exist
      
      projs = APP_CONFIG['projects']
   
    if ! @@all_branches_exist

      errors.add(:base, "nothing")
    end
  end
end
      
  

