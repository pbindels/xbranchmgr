class UserMailer < ActionMailer::Base
  default from: "netops@onekingslane.com"

  def status_email(user, project_name, branch_name, source_branch, owner_name, login, repos, repos_w_new_branch)
    @log_root = Rails.configuration.my_scope.log_root
    
    @notify = Rails.configuration.my_scope.notification_list


    @user = user
    @login = login
    
    notifies=@notify.dup
    notifies.push(@user)
    
    @project_name = project_name
    @branch_name = branch_name
    @owner_name = owner_name
    @repos = repos
    @repos_w_new_branch = repos_w_new_branch
    @source_branch = source_branch == "" ? "master" : source_branch
    @url = "https://branchmgr.newokl.com/branches"
    Rails.logger.info("#{@notify} is nofify")
    Rails.logger.info("#{@log_root} is logroot")
    Rails.logger.info("#{@user} is user")

    mail(:to => notifies, :subject => "Branch \"#{branch_name}\" creation status")
  end
end
