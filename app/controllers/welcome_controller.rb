class WelcomeController < ApplicationController
  skip_before_filter :login_required
  skip_before_filter :log_user_action

  if DEMO_APP
    include SslRequirement 
    ssl_required :index, :user_login, :signup, :add_user
  end
  
  def index
    if logged_in?
      render 'index'
    else
      render 'login'
    end
  end

  def user_login
    self.current_user = User.authenticate(params[:login], params[:password])
    # Authorization::current_user = @user   # for declarative_authorization #
    if logged_in?
      log_entry("Login")
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      render :action => 'index'
    else
      @invalid_login_flag = 1;
      flash.now[:error] = "Invalid login - please try again"
      render :action => 'login'
    end
  end

  def signup
    @user = User.new(params[:user])
    render :action => 'signup'
  end
  
  def add_user
    @user = User.new(params[:user])

    default_role = Role.find_by_name(Role::DEFAULT_ROLE) if Role::DEFAULT_ROLE
    @user.roles << Role.where('id = ?', default_role.id).all if default_role
    @user.save!

    self.current_user = @user
    log_entry("Login")
    flash.now[:notice] = "Thanks for signing up!"
    render :action => 'index'

    rescue ActiveRecord::RecordInvalid
      render :action => 'signup'
  end
  
  def logout
    log_entry("Logout")
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash.now[:notice] = "You have been logged out."
    render :action => 'login'
  end
  
protected
  def log_entry(user_action)
    logger.info("<**#{user_action}**> User: " + current_user.login + " IP: " + request.remote_ip +
                                    " Date/Time: " + Time.now.strftime("%Y-%m-%d %H:%M:%S"))
    UserLog.add_entry(self, current_user, request.remote_ip)
  end  
end
