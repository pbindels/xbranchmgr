class GitHubController < ApplicationController

  attr_accessor :github
  private :github
  
  def authorize
    @site = Rails.configuration.my_scope.site_root
    @client_id = Rails.configuration.my_scope.client_id
    @client_secret = Rails.configuration.my_scope.client_secret

    github = Github.new :client_id => @client_id, :client_secret => @client_secret

    address=github.authorize_url redirect_uri: "#{@site}/git_hub/callback", scope: 'repo'
    redirect_to address
  end

  def callback
    @site = Rails.configuration.my_scope.site_root
    @client_id = Rails.configuration.my_scope.client_id
    @client_secret = Rails.configuration.my_scope.client_secret

    github = Github.new :client_id => @client_id, :client_secret => @client_secret

    authorization_code = params[:code]
    access_token = github.get_token authorization_code
    my_token = access_token.token   # => returns token value
    session[:tok] = my_token

    respond_to do |format|
      format.html { redirect_to new_branch_path,  notice: "Branch creation complete for project", var: "#{my_token}"}
    end
  end
end