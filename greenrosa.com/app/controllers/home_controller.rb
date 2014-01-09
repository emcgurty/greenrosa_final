class HomeController < ApplicationController
  #caches_page :show
  
  def show
    do_show
  end
  
  def home

    if request.post?
      if params[:commit] == "I have read and understand the above"
        session[:i_agree] = true
        redirect_to alternative_list_url(nil)
      else
        if  session[:i_agree]
          if session[:i_agree] == true
            redirect_to alternative_list_url(nil)
          end
        end
      end
    end
  end

  def errorpage
  end

  def emailsuccess
  end

  private

  def do_show

    if (params[:id] == 'errorpage')
      render :action => 'errorpage'
    elsif (params[:id] == 'emailsuccess')
      render :action => 'emailsuccess'
    else
    
      render :action=>'index'
    end


  end

end
