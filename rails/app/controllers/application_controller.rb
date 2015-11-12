class ApplicationController < ActionController::Base
  protect_from_forgery
  

  before_filter :current_user
  before_filter :git_auth
  before_filter :get_params
  before_filter :get_all_branches

  helper_method :current_user

  def get_params
    @admins = Rails.configuration.my_scope.admins
    @projs  = Rails.configuration.my_scope.projects
  end

  def git_auth
    Rails.logger.info("--git_auth check: Access token for github is already set!")
    if session[:tok] == nil
      session[:tok] = ""
      redirect_to root_path
    end
  end

  private
  def current_user
    Rails.logger.error request.env['HTTP_REMOTE_USER']
    Rails.logger.error request.env['REMOTE_USER']
    @current_user ||=  if !request.env['HTTP_REMOTE_USER'].blank?
                    request.env['HTTP_REMOTE_USER']
                elsif !request.env['REMOTE_USER'].blank?
                    request.env['REMOTE_USER']
                else
                  nil
                end
    @current_user = "admin"  if Rails.env.development?
    if @current_user.nil?
      render nothing: true, :status => :unauthorized
      return
    end
  end
end


def get_all_branches
  @all_branches
end