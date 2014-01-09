class ApplicationController < ActionController::Base
  layout "layouts/application"
  helper :all
  protect_from_forgery :secret => CollaboratorMethods.collaborator_value[:protect_from_forgery], :only => [:update, :delete, :create]

#  def initialize
#    ##  TOT: Write a cron job Delete session table
#    Session.delete_all()
#
#  end



  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def login_required
    # Login required for a function
    unless current_user
      update_flash_and_redirect("Login is required for selected function", user_show_url)
      return false
    end
  end

  def populate_model_error_hash(field, message)
    @errors[field] = message
  end

  def update_flash_and_redirect(msg, redirect_to_url)  ## As defined in routes.rb
    flash[:notice] = msg

    respond_to do |format|
      format.html do
        redirect_to redirect_to_url
        return
      end
    end
  end

end
