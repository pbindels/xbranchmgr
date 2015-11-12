class Util
#  attr_accessible :branch_name, :date_created, :project_name, :repo_name, :owner_name, :source_branch, :ab, :hudson_job
#  attr_accessible :branches

   #@@all_branches_exist = true
  #projects = APP_CONFIG['projects']
  #products = APP_CONFIG['products']
  projects = Rails.configuration.my_scope.projects

  def validate_log(log)
    success = Hash.new
    fail = Hash.new
    messages = Hash.new
    step = 0
    flog = File.open(log,"r")
    flog.each do | line |  
      line.chomp!
      if ( line =~ /^Return Status (\d) for (.*)/i)
        step += 1
        code = $1
        task = $2
        code == "0" ? success[step] = task : fail[step] = task
      end
      
      if line =~ /(FATAL|ERROR|WARN|FAIL|ABORT|EXCEPTION)/i
        msg = $1.upcase
        if messages.has_key?(msg)
          messages[msg] = messages[msg] + 1
        else
          messages[msg] = 1
        end
      end
    end
    Rails.logger.info("#{success} is success")
    Rails.logger.info("#{fail} is fail")
    
    return messages, success, fail
  end
  
  def delete_branch (repos,branch,token,project)
    require 'openssl'

    delete_files(branch, project)

    # require 'github_api'
    # OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
    #token = Rails.configuration.my_scope.my_token
    rep_br = Array.new
    mutex = Mutex.new
    threads = []

    #Rails.logger.info "#{repos} are repos"
    repos.each do | repo |
      threads << Thread.new(repo) { |thisRepo |
        branches = ""
        github = nil
        mutex.synchronize do
          github = Github.new(:oauth_token =>  token)
          branches = github.repos.branches( :user => 'okl', :repo => repo)
        end
        new_branch_found = false
        branches.each do | branch_info |
          #Rails.logger.info "#{branch_info["name"]} - #{branch} is branch info"
          if (!new_branch_found) && ("#{branch_info["name"]}" == "#{branch}")
             new_branch_found = true

             ref = github.git_data.references.get 'okl', repo, "heads/#{branch_info["name"]}"
             Rails.logger.info("Archiving refs/heads/#{branch_info["name"]} to refs/archive/#{branch_info["name"]} with #{ref["object"]["sha"]} on #{repo} repository")
             github.git_data.references.create 'okl', repo, "ref" => "refs/tags/deleted-#{branch_info["name"]}", "sha" => "#{ref["object"]["sha"]}"

             Rails.logger.info("Deleting refs/heads/#{branch_info["name"]} from repo #{repo}")
             github.git_data.references.delete 'okl', repo, "heads/#{branch_info["name"]}"

             mutex.synchronize do
               rep_br.push(repo)
             end
          end 
        end
      }
    end
    threads.each { |aThread| aThread.join}
    return rep_br
  end

  def delete_files (branch,project)
    build_root = Rails.configuration.my_scope.build_root

    artifacts_dir            = "#{build_root}/build/artifacts/#{project}"
    artifacts_arch_dir       = "#{build_root}/build/artifacts/archive"
    jenkins_dir              = "#{build_root}/build/jenkins/jobs/#{project}-#{branch}"
    jenkins_arch_dir         = "#{build_root}/build/jenkins/ARCHIVE"
    workspace_dir            = "#{build_root}/build/hudson/workspace/#{project}-#{branch}"
    workspace_arch_dir       = "#{build_root}/build/hudson/archive"

    res1 = "default"
    res2 = "default"
    res3 = "default"

    if File.exists?("#{artifacts_dir}/#{project}-#{branch}_1.zip")
      res1 = system("mv #{artifacts_dir}/#{project}-#{branch}*zip* #{artifacts_arch_dir}")
      puts "Moving #{artifacts_dir}/#{project}-#{branch}*zip to #{artifacts_arch_dir}"
    else
      puts "#{artifacts_dir}/#{project}-#{branch} does not exist!  Nothing to archive. "
    end

    if Dir.exists?("#{jenkins_dir}")
      res2 = system("ls #{jenkins_dir}")
      puts "Moving #{jenkins_dir} to #{jenkins_arch_dir}"
      system("mv #{jenkins_dir}  #{jenkins_arch_dir}")
    else
      Rails.logger.info "#{jenkins_dir} does not exist!  Nothing to archive."
    end

    wkdir = system("ssh sfo-rel-bld-01.unix.newokl.com ls #{workspace_dir}")
    Rails.logger.info " #{workspace_dir} exists? #{wkdir} "
    if wkdir
      puts "Moving #{workspace_dir} to #{workspace_arch_dir}"
      res3 = system("ssh sfo-rel-bld-01.unix.newokl.com mv #{workspace_dir}  #{workspace_arch_dir}")
    else
      puts "#{workspace_dir} does not exist!  Nothing to archive."
    end

    #Rails.logger.info "#{res1} is res1"
    #Rails.logger.info "#{res2} is res2"
    #Rails.logger.info "#{res3} is res3"
  end
  
  def find_branch (repos,branch,token)
    rep_br = Array.new
    #token = Rails.configuration.my_scope.my_token
    github = Github.new(:oauth_token =>  token)
    src_branch_found = new_branch_found = false  
    
    repos.each do |repo|
      Rails.logger.info("Getting repo #{repo}'s branches")
      branches = github.repos.branches :user => 'okl', :repo => repo
      branches.each do | branch_info |
        rep = $1 if branch_info["commit"]["url"] =~ /http.*?\/okl\/(.*)?\/commits/
        if ("#{branch_info["name"]}" =~ /^#{branch}$/)
            rep_br.push(rep)
        end
      end
    end
    return rep_br
  end

  def get_all_branches (repos)
    index = 0
    foo = Array.new
    rep_br = Array.new
   
    repos.each do | job | 
      index += 1 
      if index < repos.length 
        Rails.logger.info(",")
      end 
      begin
        a = IO.popen("git ls-remote --heads git@github.com:okl/#{job}.git")
      rescue
        p "github is unavailable currently.  try again later!"
        return
      end
      foo.push(a) 
    end 

    str = "" 
    while foo.length > 0 
      result, = IO.select(foo, nil, nil, 10) 
      result.each do |p| 
        str = p.read 
        if p == nil 
          puts "p is nil" 
        elsif p.eof? 
          vals = str.split(/\s+/).grep(/refs/) 
          rep_br.push(vals) 
          foo.delete(p) 
        end 
      end 
    end    
    #Rails.logger.info("rep_br is #{rep_br}")
    return rep_br
  end
end