include ApplicationHelper

class UserController < ApplicationController

  def logout
    flash[:notice] = ''
    reset_session
    @current_user = nil
    session[:user_id] = nil
    redirect_to root_url
    
  end

  def show
    @is_collaborate = session[:collaborate]  if session[:collaborate]
    flash[:notice] = ''
    if request.post?
      @current_user = User.find(:first, :readonly => true, :conditions=>['username = ?', params[:user][:username]])
      if @current_user

        if @current_user.activation_code.blank? && @current_user.authenticated?(params[:user][:password])
          session[:user_id] = @current_user.user_id
          flash[:notice] = "Welcome #{get_full_name(@current_user)}"
          session[:i_agree] = true
          if session[:collaborate]
            redirect_to alternative_edit_url(nil)
          else
            redirect_to root_url
          end
        else
          unless @current_user.activation_code.blank?
            flash[:notice] = "#{get_full_name(@current_user)}, please check your email to activate your login."
            redirect_to root_url
          else @current_user.authenticated?(params[:user][:password])
            flash[:notice] = "We have entered an incorrect password."
            render :action => 'show'
          end
        end


      end
    else
    
      @user = User.new
    end
  end

  def user_record
    @record_success = false
    if request.post?
      if params[:commit] == "Submit Updates"
        @record_success = update
        if @record_success
          flash[:notice] = get_full_name(@current_user) + ", your updates have been successful"
          redirect_to root_url
        else
          ## Display errors message
          
        end
      elsif params[:commit] == "Register"
        @record_success = create
        if @record_success
          flash[:notice] = "Thanks for signing up! Please check your email to activate your account."
          redirect_to root_url
        else
          ## Display errors message
          
        end

      end

    else
      if params[:id]
        session[:user_commit] = "Submit Updates"
        @user = User.find(:first, :readonly => true,:conditions => ['user_id = ?', params[:id]])
       
      else
        session[:collaborate] = nil
        session[:feature_row] = nil
        session[:search_rows] = nil
        flash[:notice] = ''
        session[:user_commit] = "Register"
        @user = User.new
       
      end
      respond_to do |format|
        format.html
      end
    end

 
  end

  def create
    flash[:notice] = ''
   
    @user = User.new(
      :username =>   params[:user][:username],
      :first_name => params[:user][:first_name],
      :last_name =>  params[:user][:last_name],
      :mi =>         params[:user][:mi],
      :user_alias => params[:user][:user_alias],
      :email=>       params[:user][:email],
      :password=>    params[:user][:password],
      :password_confirmation => params[:user][:password_confirmation],
      :remote_ip =>             params[:user][:remote_ip],
      :display_name =>          params[:user][:display_name].to_i)
    if @user.save && @user.errors.empty?
      return true
    else
      return false
    end
   

  end

  def update
    flash[:notice] = ''
    begin
      @user = User.find(:first, :conditions=>['user_id = ?', params[:user][:user_id]])
      @user.update_attributes(
        :username =>    params[:user][:username],
        :first_name =>  params[:user][:first_name],
        :last_name =>   params[:user][:last_name],
        :mi =>          params[:user][:mi],
        :user_alias =>  params[:user][:user_alias],
        :email=>        params[:user][:email],
        :password=>     params[:user][:password],
        :password_confirmation => params[:user][:password_confirmation],
        :remote_ip =>             params[:user][:remote_ip],
        :display_name =>          params[:user][:display_name].to_i)
      @user.delete_reset_code
    rescue Exception => msg
      flash[:notice] = "Error in updating your record with system generated message: " + msg
      render :show
    else
      if @user.save()
        @current_user = @user
        session[:user_id] = @current_user.user_id
        return true
      else
        return false
      end
    end
  end








  def activate
    flash[:notice] = ''
    @user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    unless @user.activation_code.blank?
      if @user.activate
        @current_user = @user
        session[:user_id] = @current_user.user_id
        flash[:notice] = get_full_name(@current_user) + ", your registration activation is complete, and you are now logged in."
      else
        flash[:notice] = "Failure in saving record."
      end


    else
      @current_user = @user
      session[:user_id] = @current_user.user_id
      flash[:notice] = get_full_name(@current_user) + ", you have already activated your registration, and you are now logged in."


    end

    redirect_to root_url
  end
















  def forgot_password
    if request.post?
      forgot('password')
    else
      @user = User.new
    end
  end

  def forgot_username
    if request.post?
      forgot('username')
    else
      @user = User.new
    end
  end

  def forgot(which)
    flash[:notice] = ''
    if request.post?
      @user = User.find(:first, :conditions => ['email = ?', params[:user][:email]])
      respond_to do |format|
        if !(@user.blank?)
          @user.create_reset_code(which)
          if which == 'username'
            Notifier.get_username_notification(@user).deliver if @user.recently_reset? && @user.recently_username_get?
            flash[:notice] = "Path to retrieve username sent to #{@user.email}"
          else
            Notifier.reset_password_notification(@user).deliver if @user.recently_reset? && @user.recently_password_reset?
            flash[:notice] = "Path to reset password code sent to #{@user.email}"
          end
          format.html { redirect_to root_url }
          #format.xml { render :xml => @user.email, :status => :created }
        else
          flash[:error] = "#{params[:user][:email]} does not exist in system"
          format.html { redirect_to root_url }
          #format.xml { render :xml => @user.email, :status => :unprocessable_entity }
        end
      end
    end
  end

  def reset_password
    flash[:notice] = ''
    @user = User.find_by_reset_code(params[:id]) unless params[:id].nil?
    if request.post?
      if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
        @user.delete_reset_code
        flash[:notice] = "Password reset successfully for #{@user.email}. Please login"
        redirect_to root_url
      else
        render :action => :reset
      end
    end
  end

  def get_username
    flash[:notice] = ''
    @user = User.find_by_reset_code(params[:id]) unless params[:id].nil?
    if @user
      @user.delete_reset_code
      flash[:notice] = "Your username is #{@user.username}. Please login."
      redirect_to root_url
    else
      flash[:notice] = "Your username was previously reported to you. Please try to login again."
      redirect_to root_url
    end
       
  end

end