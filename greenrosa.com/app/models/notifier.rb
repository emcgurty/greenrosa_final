class Notifier < ActionMailer::Base


  def contact(params, sent_at = Time.now)

    @recipients  = CollaboratorMethods.collaborator_value[:collaborator][:email]
  
  @from        = "greenrosa@greenrosa.com"
    @sent_on     = Time.now
    @subject = "Green Rosa Contact"
    @user_alias = params[:user_alias]
    @email = params[:email]
    @comments = params[:comments]
    
  end


  def signup_notification(user)
    setup_email(user)
    @subject    += ' Please activate your new account'
    @url  = "http://"
    @url  = @url + "#{CollaboratorMethods.collaborator_value[:collaborator][:url]}/user/activate/#{user.activation_code}"
  
  end

  def activation(user)
    setup_email(user)
    @subject    += ' Your account has been activated!'
    @url  = "http://"
    @url = @url  + "#{CollaboratorMethods.collaborator_value[:collaborator][:url]}/"
  end

  def reset_password_notification(user)
    setup_email(user)
    @subject    += ' Follow this link to reset your password'
    @url  = "http://"
    @url = @url  + "#{CollaboratorMethods.collaborator_value[:collaborator][:url]}/user/reset_password/#{user.reset_code}"
  end

  def get_username_notification(user)
    setup_email(user)
    @subject    += ' Follow this link to learn your username'
    @url  = "http://"
    @url = @url  + "#{CollaboratorMethods.collaborator_value[:collaborator][:url]}/user/get_username/#{user.reset_code}"
  end

  protected
  def setup_email(user)
    @recipients  = "#{user.email}"
    @from        = CollaboratorMethods.collaborator_value[:collaborator][:email]
    @subject     = CollaboratorMethods.collaborator_value[:collaborator][:url]
    @sent_on     = Time.now
    @body[:user] = user

  end

  private

  def do_contact(params, sent_at = Time.now)

    @subject = "Green Rosa Contact"
    @recipients = params[:email]
    @from = CollaboratorMethods.collaborator_value[:collaborator][:email]
    @message = message
    @sent_on = sent_at
    @body = body
    

  end

end
