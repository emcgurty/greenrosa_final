class AdminController < ApplicationController

 
  def contact_us
    if request.post?
      if params[:commit] == "Contact Green Rosa"
        @ve = true
        @ve = valid_email(params[:contact_us][:email])  unless params[:contact_us][:email].blank?
        unless !(@ve) || (params[:contact_us][:email].blank? &&  params[:contact_us][:comments].blank? && params[:contact_us][:user_alias].blank?)

          begin
            Notifier.contact(params[:contact_us]).deliver
            flash[:notice] = "Thank you for contacting Green Rosa with your comment: #{params[:contact_us][:comments]}"
             redirect_to root_url
            return
          rescue Exception => e
            @error_msg = "Green Rosa was unable forward your 'Contact Us' email, please try later:#{e.class};#{e.message.strip}"
             redirect_to :controller => 'home', :action => 'errorpage', :error_msg => @error_msg 
            return
          end

        else
          flash_msg = ''
          if params[:contact_us][:email].blank?
            flash_msg << "<br/>Your email address is required"
          else
            @ve  ? "" : flash_msg << "<br/>Your email address is not properly formatted"
          end
          if params[:contact_us][:comments].blank?
            flash_msg << "<br/>Your comment is required"
          end
          if params[:contact_us][:user_alias].blank?
            flash_msg << "<br/>Your subject is required"
          end
          flash[:notice] = flash_msg
          #          @contact_us = Array.new
          #          @contact_us << {"email" => params[:contact_us][:email], "comments" => params[:contact_us][:comments], "user_alias" => params[:contact_us][:user_alias]}
          #          respond_to do |format|
          #            format.html
          #          end
        end
      end
    
    else
      @contact_us = Array.new
      @contact_us << {"email" => '', "comments" => '', "user_alias" => ''}
      respond_to do |format|
        format.html
      end
    end

  end
  
  ## TODO Update for current application
  def tables_to_approve
  end

  private

  def valid_email(email)
    email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    if params[:contact_us][:email] =~ email_regex
      return true
    else
      return false
    end
  end


  def update_approvals(table)
    @count_of_records = params[:count].to_i
    @counter = 0
    @count_of_records.times do
      @counter = @counter + 1
      if table == 'a'
        @tmp = Aternative.find(params["id_#{@counter}"])
      end
      if params["approved_#{@counter}"]
        @a_value = true
      else
        @a_value = false
      end
      @tmp.update_attributes(:record_text => params["text_#{@counter}"], :approved => @a_value )
      
    end
  end

end
