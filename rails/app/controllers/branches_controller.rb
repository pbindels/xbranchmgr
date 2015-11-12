class BranchesController < ApplicationController

  require 'github_api'
 
  after_filter :clear_lock
  before_filter :get_branch, :only => [ :show, :update, :destroy, :edit ]
  before_filter :get_repos, :only => [ :delete_branch_across_repos, :find_branch_across_repos, :get_branches, :index]

  def get_branch
    @branch = Branch.find(params[:id])
  end
  
  def clear_lock 
    if File.exists?("#{session[:lock]}") && session[:status]
      File.delete(session[:lock])
    end
  end

  def do_task
    @task_name = params[:task_name]
    case @task_name
      when /delete an existing branch/i;             render '/branches/delete_branch'
      when /create a new branch/i;                   redirect_to new_branch_path
      when /list branches for a project/i;           render '/branches/get_branches'
      when /list branches for a specific repo/i;     render '/branches/list_branches'
      when /find a branch/i ;                        render 'branches/find_branch'
      when /create a new repository/i;               render 'branches/create_repo'
      when /list deployment environments/i;          @deploy_envs = DeployEnv.all; render '/deploy_envs/index'
      when /add a deployment environment/i;          @deploy_env = DeployEnv.new; render 'deploy_envs/new'
      else
        respond_to do |format|
          format.html  # index.html.erb
          format.json { render json: @branches }
        end
    end
  end

  def get_repos
    @branches = Branch.all
    @allprojs = Rails.configuration.my_scope.projects
    @branch_name = params[:branch_name]
    @project_name = params[:project_name] != nil ? params[:project_name] : "netops"
    @repo_name = params[:repo_name] ? params[:repo_name] : "all"
    #@all_repos = Array.new

    if @repo_name == "all"
      @all_repos = @allprojs[@project_name]
    else
      #@all_repos.push(@repo_name)
      @all_repos = Array(@repo_name)
    end
  end

  # GET /branches
  # GET /branches.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @branches }
    end
  end

  # GET /branches/1
  # GET /branches/1.json
  def show
    @log_root = Rails.configuration.my_scope.log_root

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @branch }
    end
  end

  def filterException(e)
    Rails.logger.info("#{e.message} - #{e.backtrace.inspect}")
    if e.message =~ /422 name already exists/
      msg = "repository already exists"
    else
      msg = e.message
    end
    return msg
  end

  def create_new_repository
    @repo_name = params[:new_repo_name]
    github = Github.new( :oauth_token => session[:tok])
    return_from_actions = github.repos.actions

    begin
      github.repos.create "name" => @repo_name, "org" => 'okl', "private" => true,  "description" => "Test Repo Creation"
    rescue Exception => e
      val = filterException(e)
      render "/branches/standard_error.html.erb", :locals => {:var => val }
      return
    end

    respond_to do |format|
      format.html
      format.json { render json: @branch }
    end
  end

  def delete_repository
    @log_root = Rails.configuration.my_scope.log_root
    @repo_name = params[:new_repo_name]

    github = Github.new( :oauth_token => session[:tok])
    return_from_actions = github.repos.actions

    #requires admin and delete_repo scope!
    #return_from_delete_repo = github.repos.delete "name" => @repo_name, "org" => 'okl'

    respond_to do |format|
      format.html
      format.json { render json: @branch }
    end
  end

  # GET /branches/new
  # GET /branches/new.json
  def new
    @branch = Branch.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @branch }
    end
  end

  def delete_branch
    @branch = Branch.new
    respond_to do |format|
      format.html # delete_branch.html.erb
      format.json { render json: @branch }
    end
  end

  # GET /branches/1/edit
  def edit
    #@branch = Branch.find(params[:id])
  end

  # POST /branches
  # POST /branches.json
  def create
    params[:branch][:date_created] = Time.now
    params[:branch][:owner_name] = @current_user
    @branch = Branch.new(params[:branch])
    projs = Rails.configuration.my_scope.projects
    jenkins_projects = projs.keys
    @log_root = Rails.configuration.my_scope.log_root
    @rails_root = Rails.configuration.my_scope.rails_root
    @create_timeout = Rails.configuration.my_scope.create_timeout
    repos_wo_branch = Array.new
    repos_w_new_branch = Array.new
    project_name = @branch[:project_name]
    branch_name = @branch[:branch_name]
    source_branch = @branch[:source_branch]
    owner_name = @branch[:owner_name]
    jenkins_job = @branch[:hudson_job]
    dep_host_name = params[:dep_host_name]
    session[:status] = true
    @all_repos = projs[project_name]


    flog = File.open("#{@log_root}/#{project_name}\-#{branch_name}.log", "a")

    if session[:tok] == nil
      Rails.logger.info("Access token is not set, redirecting to github authorize")
      redirect_to root_path
    end

    # Set lock in case two people try to create branch of same name simultaneously
    session[:lock] = "#{@log_root}\/#{branch_name}.lock"
    iterations = 0
    while File.exists?("#{session[:lock]}") && (iterations < @create_timeout.to_i / 10) do
      Rails.logger.info("Waiting for #{session[:lock]} to clear...sleep 10.")
      iterations += 1
      sleep 10
    end

    if File.exists?("#{session[:lock]}")
      Rails.logger.info("Branch #{branch_name} has been locked for #{@create_timeout} seconds")
      msg = "Branch #{branch_name} has been locked for #{@create_timeout} seconds... Please check with netops why #{session[:lock]} exists."
      render "/branches/standard_error.html.erb", :locals => { :var => msg }
      session[:status] = false
      return
    end

    flock = File.open("#{session[:lock]}","w")
    flock.puts "Running Create Branch for branch: #{branch_name}" 
    flock.flush

    threads = []
    mutex = Mutex.new
    @all_repos.each do |repo|
      threads << Thread.new(repo) { |thisRepo|
        github = nil
        mutex.synchronize do
          if github == nil            
            github = Github.new( :oauth_token => session[:tok])
          end
        end
        
        refs_for_repo=""
        return_from_create=""
        mutex.synchronize do
          refs_for_repo = github.git_data.references.list 'okl', repo, ref:'heads'
        end

        src_branch_found = new_branch_found = false
        sha_of_source = ""
        refs_for_repo.each do | entry |
          ref = entry["ref"]
          if (!src_branch_found) && (ref =~ /^refs\/heads\/#{source_branch}$/)
            src_branch_found = true
            sha_of_source = entry["object"]["sha"]
          end
          if (!new_branch_found) && (ref =~ /^refs\/heads\/#{branch_name}$/)
            new_branch_found = true
            #repos_w_new_branch.push("#{repo}:#{branch_name}")
            repos_w_new_branch.push(repo)
          end
          break if src_branch_found && new_branch_found
        end
        if src_branch_found
          if ! repos_w_new_branch.include?(repo)
            return_from_create = return_from_tag = ""
            mutex.synchronize do
              # Create the branch.
              begin
                return_from_create = github.git_data.references.create 'okl', "#{repo}", "ref" => "refs/heads/#{branch_name}", "sha" => "#{sha_of_source}"
              rescue
                Rails.logger.info("Error in github create branch for #{branch_name} in repo #{repo} -> #{return_from_create}")
                render "/branches/standard_error.html.erb"
              end

              # For king releases, we want to make a gold tag for each release so we can diff between releases.
              if project_name == "king" && branch_name =~ /release_\d*/
                begin
                  return_from_tag = github.git_data.references.create 'okl', "#{repo}", "ref" => "refs/tags/#{branch_name}_gold", "sha" => "#{sha_of_source}"
                rescue
                  Rails.logger.info("Error in github create tag for #{branch_name}_gold in repo #{repo} -> #{return_from_tag}")
                  render "/branches/standard_error.html.erb"
                end
              end

              begin
                return_from_tag = github.git_data.references.create 'okl', "#{repo}", "ref" => "refs/tags/build-#{project_name}-#{branch_name}_0", "sha" => "#{sha_of_source}"
              rescue
                Rails.logger.info("Error in github create tag for build-#{project_name}-#{branch_name}_0 in repo #{repo} -> #{return_from_tag}")
                render "/branches/standard_error.html.erb"
              end
            end
          end
          Rails.logger.info("Returning from create branch #{thisRepo} -  #{return_from_create}")
          Rails.logger.info("Returning from create tag #{thisRepo} -  #{return_from_tag}")
        else
          mutex.synchronize do
            repos_wo_branch.push("#{repo}:#{source_branch}")
          end
        end
      }
    end
    threads.each { |aThread| aThread.join }

    session[:repos_w_new_branch] = repos_w_new_branch
    session[:repos] = @all_repos

    #if repos_w_new_branch.length > 0
    #  render "/branches/error_new_branch.html.erb", :locals => {:var => repos_w_new_branch, :proj => project_name}
    #  return
    #end

    if repos_wo_branch.length > 0
      render "/branches/error_src_branch.html.erb", :locals => {:var => repos_wo_branch, :proj => project_name}
      return
    end
  
    if Rails.env != "development" 
      #  system("#{@rails_root}/lib/utility/chk_branch.sh  #{project_name} #{branch_name} #{source_branch} > #{@log_root}/#{project_name}\-#{branch_name}.log  2>&1")
      if jenkins_job && jenkins_projects.include?(project_name)
        system("#{@rails_root}/lib/utility/chk_jenkins.sh  #{project_name} #{branch_name} #{dep_host_name} >> #{@log_root}/#{project_name}\-#{branch_name}.log  2>&1")
      else
        system("echo \"Jenkins job has not been selected\" >> #{@log_root}/#{project_name}\-#{branch_name}.log")
      end
    else
      Rails.logger.info("DEV, NOT Executing\n#{@rails_root}/lib/utility/chk_branch.sh #{project_name} #{branch_name} #{source_branch} > #{@log_root}/#{project_name}\-#{branch_name} 2>&1")
      system("echo \"DEV environment...not creating branch with chk_branch.sh! \" >> #{@log_root}/#{project_name}\-#{branch_name}.log 2>&1")
      if jenkins_job  && jenkins_projects.include?(project_name)
        Rails.logger.info("DEV, NOT Executing...\n#{@rails_root}/lib/utility/chk_jenkins.sh #{project_name} #{branch_name} > #{@log_root}/#{project_name}\-#{branch_name} 2>&1")
        system("echo \"DEV environment...not creating jenkins job with chk_jenkins.sh! \" >> #{@log_root}/#{project_name}\-#{branch_name}.log 2>&1")
      end
    end
    Rails.logger.flush


    respond_to do |format|
      if @branch.save
        UserMailer.status_email("pbindels@onekingslane.com",project_name, branch_name, source_branch, owner_name, @current_user, @all_repos, repos_w_new_branch).deliver
        format.html { redirect_to @branch,  notice: "Branch creation complete for project \"#{project_name}\": ", var: "#{project_name}", reps: "#{repos_w_new_branch}"}
        format.json { render json: @branch, status: :created, location: @branch }
      else
        format.html { render action: "new" }
        format.json { render json: @branch.errors, status: :unprocessable_entity }
      end  
    end  
  end

  def delete_branch_across_repos
    respond_to do |format|
      format.html  # index.html.erb
      format.json { render json: @branches }
     end
  end

  def find_branch_across_repos
    respond_to do |format|
      format.html
      format.json { render json: @branches }
     end
  end

  def get_branches
    respond_to do |format|
      format.html { render action: "get_branches", var: @project_name }# index.html.erb
      format.json { render json: @branches }
    end
  end

  # PUT /branches/1
  # PUT /branches/1.json
  def update
    respond_to do |format|
      if @branch.update_attributes(params[:branch])
        format.html { redirect_to @branch, notice: 'Branch was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @branch.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /branches/1
  # DELETE /branches/1.json
  def destroy
    @branch.destroy
    respond_to do |format|
      format.html { redirect_to branches_url }
      format.json { head :no_content }
    end
  end
end
