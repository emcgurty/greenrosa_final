class AlternativeController < ApplicationController

  require 'rosa'
  require 'rosa_features'
  before_filter :login_required, :except => [:list, :search, :feature_search, :collaborate, :download]
  
  ## @alternative is used interchangeably depending on context, either real Alternative or 'cart' Rosa.
  ## Rosa is used to temporarily store data to minimize database interaction
  ## Also in the call back to add a feature row, if I am using a model the addition of a new child requires that I save the parent.
  def edit
    flash.clear()
    session[:hold_save_result] = nil
    session[:search_rows] = nil
    @return_value = true
    unless request.post?
      unless params[:id].blank?
        @mysql_find = "SELECT alternatives.*, features.*  FROM alternatives INNER JOIN features  ON alternatives.id = features.alternative_id WHERE alternatives.id = #{params[:id]} ORDER BY alternatives.created_at"
        @tmp_instance = Alternative.find_by_sql(@mysql_find)
        session[:feature_rows] = @tmp_instance.count.to_i
        @alternative = send_one_to_rosa(@tmp_instance)
      else
        session[:feature_rows] = 1
        @alternative = Array.new
        @alternative = send_data_to_rosa('')
      end
    else
      if params[:commit] == "Submit for Edit Approval"
        @return_value = do_update
        if @return_value
          session[:collaborate] = nil
          session[:upload_file] = nil
          session[:source_irl] = nil
          redirect_to root_url
        else
          source_url_session_variables
          @alternative = get_rosa
        end
      elsif 

params[:commit]  == "Clear Entries"
    
   if params[:id]
          Alternative.delete_all(:id =>params[:id])
        else
          session[:feature_rows] = 1
          @alternative = send_data_to_rosa('')
        end


 elsif params[:commit]  == "Add Another Feature"
        do_add_new_resource
        @alternative = Array.new
        @alternative = get_rosa
      

elsif params[:commit] == "Changed My Mind"
 
 if params[:id]
          Alternative.delete_all(:id =>params[:id])
        end
        if session[:collaborate]
          session[:collaborate] = nil
          flash[:notice] = "Maybe later you will Green Rosa collaborate on an application."
        else
          flash[:notice] = "Maybe later you will complete your creating or editting a Green Rosa application."
        end     
  end
        @tmp_col = nil
        redirect_to root_url
      end
    end
    @tmp_instance = ''
  
  end

  def collaborate
    flash[:notice] = ''
    session[:collaborate] = params[:id]
    ## On event of collaborate, managed by User Controller. The following does nothing, but controller complains without it.
    redirect_to :controller => 'alternative', :action => 'edit', :id => nil, :is_collaborate => true
  end

  def feature_search
    flash[:notice] = ''
   
    @search = Array.new
    ct = 1
    unless session[:search_rows]
      session[:search_rows] = 1
      @remaining_rows = (CollaboratorMethods.collaborator_value[:display_search_rows][:max].to_i) - (session[:search_rows].to_i)
      
      @search << { "and_or_1" => 1, "name_1" => '' ,  "list_1" => '' }
    else
      if params[:commit] == 'Add Another Search Row'
        session[:search_rows].times do
          @search << { "and_or_#{ct}" => params["and_or_#{ct}"], "name_#{ct}" => params[:search]["name_#{ct}"], "list_#{ct}" => params[:search]["list_#{ct}"] }
          ct = ct +1
        end
        session[:search_rows] = session[:search_rows] + 1
        @remaining_rows = (CollaboratorMethods.collaborator_value[:display_search_rows][:max].to_i) - (session[:search_rows].to_i)
        flash[:notice] =  "#{@remaining_rows} remaining search rows"
        @search << { "and_or_#{ct}" => '', "name_#{ct}" => '' ,  "list_#{ct}" => '' }
      elsif params[:commit] == 'Search'
                
        if search_rows?

          @alternative = Array.new
          @alternative = search
          session[:search_rows] = nil
          @alternative
          render :action => 'list'
        else
          flash[:notice] = "Please provide search criteria. Green Rosa Word Search view has been refeshed."
          session[:search_rows] = 1
          @search << { "and_or_1" => 1, "name_1" => '' ,  "list_1" => '' }
        end

      elsif params[:commit] == 'Changed My Mind'
        session[:search_rows] = nil
        redirect_to root_url
      
      end
    end
  end

  def download

    ## Does not work consistently in FireFox.
    @hold_param = params[:name]
    @tmp_alternative = Alternative.find(:first, :conditions => ['file_name = ?',@hold_param], :readonly => true)
    @file_content_type = @tmp_alternative.content_type.to_s
    @file_name  = "#{Rails.root}/collaborator/source_files/#{@tmp_alternative.file_name}"
    send_file @file_name, :disposition => "attachment", :type => @file_content_type
  end


  def list
    flash[:notice] = ''
    session[:search_rows] = nil

    if params.count == 2
      # Just action and controller
      session[:collaborate] = nil
    end
     
    if params[:id] && !(params[:id].blank?)
      if params[:id].include?("status_")
        @tmp_chomped = get_after_underscore(params[:id].to_s,"status_")
        @tmp_instance = Alternative.find(:all, :include => :features, :joins => :features, :readonly => true, :conditions => ['application_status = ?',@tmp_chomped.to_i ])
        @tmp_instance = @tmp_instance.uniq
        @alternative = send_data_to_rosa(@tmp_instance)
      elsif params[:id].include?('name_')
        @tmp_chomped = get_after_underscore(params[:id].to_s,"name_")
        @tmp_instance = Alternative.find(:all, :include => :features, :joins => :features, :readonly => true, :conditions => ['application_name= ?',@tmp_chomped])
        @tmp_instance = @tmp_instance.uniq
        @alternative = send_data_to_rosa(@tmp_instance)
      elsif params[:id].include?('alias_')
        @tmp_chomped = get_after_underscore(params[:id].to_s,"alias_")
        @tmp_find_alias_user_id = User.find(:first, :readonly => true, :conditions => ['user_alias = ?',@tmp_chomped])
        @tmp_instance = Alternative.find(:all, :include => :features, :joins => :features, :readonly => true, :conditions => ['user_id = ?',@tmp_find_alias_user_id.user_id ])
        @tmp_instance = @tmp_instance.uniq
        @tmp_find_alias_user_id = nil
        @alternative = send_data_to_rosa(@tmp_instance)
      else
        @tmp_instance = Alternative.find(:first, :include => :features, :joins => :features, :readonly => true, :conditions => ['alternatives.id = ?', params[:id]])
        session[:feature_rows] = @tmp_instance.count.to_i
        @alternative = send_data_to_rosa(@tmp_instance)
      end
      params[:id] = ''
      @tmp_instance = nil
      @tmp_chomped = nil


    else
      @tmp_instance = Alternative.find(:all, :readonly => true)
      @alternative = send_data_to_rosa(@tmp_instance)
    end
    
    respond_to do |format|
      format.html
    end
  end

  def delete
    flash[:notice] = ''
    destroy_this
    redirect_to :action => 'list', :id => nil
  end

  def create
    flash[:notice] = ''
    
    if params[:commit]  == "Add Another Feature"
      do_add_new_resource
    elsif params[:commit] == "Changed My Mind"
      if params[:alternative][:id].blank?
        destroy_this
      else
        flash[:notice] = "Perhaps you will submit your Green Rosa Application, or application revisions later."
      end
      redirect_to root_url

    elsif params[:commit]  == "Submit Updates for Approval"
      do_update
    end

  end

  private

  def search_rows?
    ct = 1
    @row_not_complete = false
    session[:search_rows].times do
      if params[:search]["name_#{ct}"].blank? && params[:search]["list_#{ct}"].blank?
        @row_not_complete = false
      else
        @row_not_complete = true
        break
      end
      ct = ct + 1
    end
    @row_not_complete
  end


  def search
    ##  Build SQL LIKE statements. Not tested thoroughly
    @return_sql_result = Array.new
    ct = 1

    session[:search_rows].times do
      hold_name = "%#{params[:search]["name_#{ct}"].to_s.strip}%"
      hold_list = "%#{params[:search]["list_#{ct}"].to_s.strip}%"
      if params["and_or_#{ct}"]  == '1'
        if !(params[:search]["name_#{ct}"].blank?) && !(params[:search]["list_#{ct}"].blank?)
          @tmp_recordset = Alternative.find(:all, :include => :features, :joins => :features, :readonly => true , :conditions => [
              'application_name LIKE ? AND record_text LIKE ?', hold_name,  hold_list])
          if  @tmp_recordset
            @return_sql_result << @tmp_recordset.uniq
          end
            
        end
      elsif params["and_or_#{ct}"]  == '2'
        if !(params[:search]["name_#{ct}"].blank?) && !(params[:search]["list_#{ct}"].blank?)
          @tmp_recordset = Alternative.find(:all, :include => :features, :joins => :features, :readonly => true , :conditions => [
              'application_name LIKE ? OR record_text LIKE ?', hold_name,  hold_list])
          if  @tmp_recordset
            @return_sql_result << @tmp_recordset.uniq
          end

        end
      end
      ct = ct + 1
       
    end
    @return_sql_result
  end

  def do_update
    ## TODO Combined call for event of update and new
    if session[:user_id]
      u_id = session[:user_id]
    else
      u_id = ''
    end

    @error_return = true
    @errors_count = 0
    session[:hold_save_result] = Array.new

    source_url_session_variables
    @rosa_updated = false
    @res_url = build_res_url
    @a_status = 0
    @a_status = params[:application_status].to_i
    if session[:file_size]
      @file_size_provided = session[:file_size].to_s
    else
      @file_size_provided = ''
    end
    @update_done = false
    @alternative =  Alternative.find(:first, :conditions=>['id = ?', params[:id]])
    unless @alternative.blank?
      ## Below is that there is not save on update ;(

      begin
        @alternative.update_attributes(
          :source_url => @res_url[:source_url],
          :content_type => @res_url[:content_type],
          :file_name => @res_url[:file_name],
          :file_size => @file_size_provided,
          :application_name => params[:alternative][:application_name],
          :application_description => params[:alternative][:application_description],
          :application_ide => params[:alternative][:application_ide],
          :application_status => @a_status,
          :ruby_version => params[:alternative][:ruby_version],
          :rails_version => params[:alternative][:rails_version],
          :remote_ip => params[:alternative][:remote_ip],
          :user_id => u_id,
          :approved => 0)
      rescue ActiveRecord::RecordNotFound
        error_msg = "Record not found in 'Changed My Mind' application offering function"
        redirect_to :controller=>'home', :action=>'error_page', :error_msg => error_msg
      rescue ActiveRecord::ActiveRecordError
        error_msg = "Active Record Error in 'Changed My Mind' application offering function"
        redirect_to :controller=>'home', :action=>'error_page', :error_msg => error_msg
      else
        @update_done = true
      end
      
    
    else

      begin
        @alternative = Alternative.new(
          :source_url => @res_url[:source_url],
          :content_type => @res_url[:content_type],
          :file_name => @res_url[:file_name],
          :file_size => @file_size_provided,
          :application_name => params[:alternative][:application_name],
          :application_description => params[:alternative][:application_description],
          :application_ide => params[:alternative][:application_ide],
          :application_status => @a_status,
          :ruby_version => params[:alternative][:ruby_version],
          :rails_version => params[:alternative][:rails_version],
          :remote_ip => params[:alternative][:remote_ip],
          :user_id => u_id,
          :approved => 0)
      rescue ActiveRecord::RecordNotFound
        error_msg = "Record not found in 'Changed My Mind' application offering function"
        redirect_to :controller=>'home', :action=>'error_page', :error_msg => error_msg
      rescue ActiveRecord::ActiveRecordError
        error_msg = "Active Record Error in 'Changed My Mind' application offering function"
        redirect_to :controller=>'home', :action=>'error_page', :error_msg => error_msg
      else
         @did_it_save = @alternative.save()
      end
      

    end  ## ends unless alternative blank
   
    session[:hold_save_result][0] = @alternative
    check_disregard = ""
    if @did_it_save || @update_done
      ct = 1
      Feature.destroy_all(:alternative_id => @alternative.id )
      @hold_feature_rows =  session[:feature_rows]
      @hold_feature_rows.times do
        unless params["rt_#{ct}"].blank?
          unless params["deo_#{ct}"]
            @offer = @alternative.features.create(:record_text => params["rt_#{ct}"])
          else
            check_disregard = check_disregard + params["rt_#{ct}"]
            ct < @hold_feature_rows ? check_disregard + ", " : ""
            #session[:feature_rows] = session[:feature_rows] - 1
          end
        else
          #session[:feature_rows] = session[:feature_rows] - 1
        end
        ct = ct + 1
      end
    end
    session[:hold_save_result][1] =  @offer if @offer

    if @offer
      if @offer.errors.blank?
        flash[:notice] = "Your Green Rosa Application #{params[:alternative][:application_name]} submission with features has been updated."
        @error_return = true
        @error_return
      else
        flash[:notice] = "There were data errors or ommissions in your Green Rosa submission."
        unless @alternative.new_record?
          @new_id = @alternative[:id]
          @alterantive = nil
          Alternative.delete_all(:id => @new_id)
        end
        @error_return = false
        @error_return
      end
    else
      ## TODO Pluralize features
      flash[:notice] = "There were data errors or ommissions in your Green Rosa submission. \r\n The following Feature(s) were checked for Disregard: #{check_disregard}."
      session[:feature_rows] == 0 ? session[:feature_rows] = 1 : session[:feature_rows]  = session[:feature_rows]
      unless @alternative.new_record?
        @new_id = @alternative[:id]
        @alternative = nil
        Alternative.delete_all(:id => @new_id)
      end
      @error_return = false
      @error_return
    end
  end  ## end def

  
  def destroy_this
    
    unless params[:id].blank?
      @lid = Alternative.find(params[:id])
    else
      @lid = Alternative.find(params[:alternative][:id])
    end
    @content_lid = @lid.id
    @app_name = @lid.application_name
    begin
      if @app_name
        unless @lid.file_size.blank?
          name = @lid.file_name
          directory = "#{Rails.root.to_s}/collaborator/source_files"
          path = File.join(directory, name)
          begin
            File.delete(path)
          rescue
          end
        end
        ## Cascading exception re: delete of has_many with belongs_to does not work consistently
        Alternative.delete_all(:id => @content_lid)
        Feature.delete_all(:alternative_id => @content_lid)
        
        if session[:collaborate]
          Collaborate.delete_all(:alternative_id => @content_lid)
        end
        @lid = nil
      else
        flash[:notice] ="Unable to delete selected Green Rosa application: #{params[:alternative][:application_name]}.  Please try later."
      end

    rescue ActiveRecord::RecordNotFound
      error_msg = "Record not found in 'Changed My Mind' application offering function"
      redirect_to :controller=>'home', :action=>'error_page', :error_msg => error_msg
    rescue ActiveRecord::ActiveRecordError
      error_msg = "Active Record Error in 'Changed My Mind' application offering function"
      redirect_to :controller=>'home', :action=>'error_page', :error_msg => error_msg
    else
      if params[:commit] == "Changed My Mind"
        flash[:notice] = "#{@app_name} record was not saved to the database."
       
      else
        flash[:notice] = "#{@app_name}, your application record has been deleted."
       
      end
    end

  end

  def do_add_new_resource
  
    session[:feature_rows] = session[:feature_rows] + 1
    session[:remaining_resource_rows] = CollaboratorMethods.collaborator_value[:display_resources][:max].to_i - session[:feature_rows]
    if session[:remaining_resource_rows].to_i == 0
      flash[:notice] = "Sorry, no more remaining feature rows."
    else
      flash[:notice] = "You can add #{session[:remaining_resource_rows]} more feature rows."
    end

  end
  
  def get_after_underscore(stack, needle)
    stack.sub(needle, "")
  end


  def source_url_session_variables
    if request.post?
      if params[:alternative][:uploaded_zip_file]
        unless params[:alternative][:uploaded_zip_file].blank?
          session[:upload_file] = base_part_of(params[:alternative][:uploaded_zip_file].original_filename)
          
        else
          session[:upload_file] = nil
        end
      end

      if params[:alternative][:repository]
        unless params[:alternative][:repository].blank?
          session[:source_url] = params[:alternative][:repository]
        else
          session[:source_url] = nil
        end
      end
    else
      session[:source_url] = nil
      session[:upload_file] = nil
    end
  end

  def send_data_to_rosa(alternative_object)
    @return_array = Array.new

    unless alternative_object.blank?
      if alternative_object.instance_of?(Alternative)
        if alternative_object.file_name == 'NA'
          session[:source_url] = alternative_object.source_url
          session[:upload_file] = ''
        else
          session[:source_url] = ''
          session[:upload_file] = alternative_object.source_url
        end
        @rosa = Rosa.new
        @rosa.id = alternative_object.id
        @rosa.user_id = alternative_object.user_id.blank? ? session[:user_id] ? session[:user_id]: '' : alternative_object.user_id
        @rosa.application_name = alternative_object.application_name
        @rosa.application_description = alternative_object.application_description
        @rosa.ruby_version = alternative_object.ruby_version
        @rosa.rails_version = alternative_object.rails_version
        @rosa.application_ide = alternative_object.application_ide
        @rosa.application_status = alternative_object.application_status.to_i
        @rosa.source_url = alternative_object.source_url
        @rosa.file_name = alternative_object.file_name
        @rosa.file_size = alternative_object.file_size
        #@features = Feature.find(:all, :readonly => true, :conditions => ['alternative_id = ?',alternative_object.id])
        unless alternative_object.features.blank?
         
          alternative_object.features.each do |ft|
            @rosafeatures = RosaFeatures.new
            @rosafeatures.record_text = ft.record_text
            @rosafeatures.destroy_feature = false
            @rosa.features << @rosafeatures
          end
        end

        @return_array << @rosa

      elsif !(alternative_object.instance_of?(Alternative))
        alternative_object.each do |tmp|
          if tmp.file_name == 'NA'
            session[:source_url] = tmp.source_url
            session[:upload_file] = ''
          else
            session[:source_url] = ''
            session[:upload_file] = tmp.source_url
          end

          @rosa = Rosa.new
          @rosa.id = tmp.id
          @rosa.user_id = tmp.user_id.blank? ? session[:user_id] ? session[:user_id]: '' : tmp.user_id
          @rosa.application_name = tmp.application_name
          @rosa.application_description = tmp.application_description
          @rosa.ruby_version = tmp.ruby_version
          @rosa.rails_version = tmp.rails_version
          @rosa.application_ide = tmp.application_ide
          @rosa.application_status = tmp.application_status.to_i
          @rosa.source_url = tmp.source_url
          @rosa.file_name = tmp.file_name
          @rosa.file_size = tmp.file_size
          # @features = Feature.find(:all, :readonly => true, :conditions => ['alternative_id = ?',tmp.id])
          unless tmp.features.blank?
            tmp.features.each do |ft|
              @rosafeatures = RosaFeatures.new
              @rosafeatures.record_text = ft.record_text
              @rosafeatures.destroy_feature = false
              @rosa.features << @rosafeatures
            end
          end
          @return_array << @rosa
        end
        
      end
 
    
    else
    
      session[:source_url] = ''
      session[:upload_file] = ''
      @rosa = Rosa.new
      @rosa.id = ''
      @rosa.user_id = session[:user_id] ? session[:user_id]: ''
      @rosa.application_name = ''
      @rosa.application_description = ''
      @rosa.ruby_version = ''
      @rosa.rails_version = ''
      @rosa.application_ide = ''
      @rosa.application_status = ''
      @rosa.source_url = ''
      @rosa.file_name = ''
      @rosa.file_size = ''
        
      @rosafeatures = RosaFeatures.new
      @rosafeatures.record_text = ''
      @rosafeatures.destroy_feature = false
      @rosa.features << @rosafeatures
      @return_array << @rosa
    end
    @rosa = nil
    @return_array
  end

  def send_one_to_rosa(alternative_object)
    @return_array = Array.new
    @only_once = true
    @rosa = Rosa.new
    alternative_object.each do |ao|
      if ao.file_name == 'NA'
        session[:source_url] = ao.source_url
        session[:upload_file] = ''
      else
        session[:source_url] = ''
        session[:upload_file] = ao.source_url
      end

      if @only_once
        @rosa.id = ao.id
        @rosa.user_id = ao.user_id.blank? ? session[:user_id] ? session[:user_id]: '' : ao.user_id
        @rosa.application_name = ao.application_name
        @rosa.application_description = ao.application_description
        @rosa.ruby_version = ao.ruby_version
        @rosa.rails_version = ao.rails_version
        @rosa.application_ide = ao.application_ide
        @rosa.application_status = ao.application_status.to_i
        @rosa.source_url = ao.source_url
        @rosa.file_name = ao.file_name
        @rosa.file_size = ao.file_size
      end
    
      @rosafeatures = RosaFeatures.new
      @rosafeatures.record_text = ao.record_text
      @rosafeatures.destroy_feature = false
      @only_once = false
      @rosa.features << @rosafeatures
      @return_array << @rosa
    end
 
    @return_array
  end

  def build_res_url

    @res_url =  {:source_url => '', :content_type => '', :file_name => '' }
    @b_r = false
    @b_z = false
    if params[:alternative][:repository]
      unless params[:alternative][:repository].blank?
        @b_r = true
      end
    end

    if params[:alternative][:uploaded_zip_file]
      unless params[:alternative][:uploaded_zip_file].blank?
        @b_z = true
      end
    end

    if @b_z && !(@b_r)
      @res_url = uploaded_zip_file(params[:alternative][:uploaded_zip_file])
    elsif !(@b_z) && @b_r
      @res_url = {:source_url => params[:alternative][:repository], :content_type => 'NA', :file_name => 'NA' }
    else
      @res_url =  {:source_url => '', :content_type => '', :file_name => '' }
    end
    @res_url
  end

  def uploaded_zip_file(temp_file)
    name = ''
    unless (temp_file.blank?)
      name = base_part_of(temp_file.original_filename)
      directory = "#{Rails.root.to_s}/collaborator/source_files"
      path = File.join(directory, name)
      File.open(path, "wb") { |f| f.write(temp_file.read) }
      megabyte = 1024
      file_size = ((File.size(path).to_i)/megabyte)
      uppercase_extension = getfileextension(name)
      if file_size <= 500 && !uppercase_extension

        session[:file_size] = file_size
        return  {:source_url => name, :content_type => temp_file.content_type.chomp, :file_name => name }
      else
        File.delete(path)
        return  {:source_url => '', :content_type => 'invalid', :file_name => name }
      end
    end
  end

  def getfileextension(filename)
    @returned_value = false
    dot_location = (filename =~ /(\.[^\.]*)$/)
    dot_location = dot_location + 1
    uppercase_extension = filename.slice(dot_location..filename.size).upcase
    if CollaboratorMethods.collaborator_value[:executable_files][0].include?(uppercase_extension)
      @returned_value = true
    else
      @return_value = false
    end
    @returned_value
  end


  def base_part_of(filename)
    File.basename(filename).gsub(/[^\w._-]/, '')
  end

  def get_rosa
   
    session[:source_url] = ''
    session[:upload_file] = ''

    if params[:alternative][:uploaded_zip_file]
      unless  params[:alternative][:uploaded_zip_file].blank?
        session[:source_url] = ''
        session[:upload_file] = base_part_of(params[:alternative][:uploaded_zip_file].original_filename)
      end
    end

    if params[:alternative][:repository]
      unless  params[:alternative][:repository].blank?
        session[:source_url] = params[:alternative][:repository]
        session[:upload_file] = ''
      end
    end

    if params[:alternative][:repository] && params[:alternative][:uploaded_zip_file]
      if  !(params[:alternative][:uploaded_zip_file].blank?)  && !(params[:alternative][:repository].blank?)
        session[:source_url] = params[:alternative][:repository]
        session[:upload_file] = base_part_of(params[:alternative][:uploaded_zip_file].original_filename)
      end
    end
    @rosa = Rosa.new
    @rosa.id = params[:alternative][:id]
    @rosa.user_id = params[:alternative][:user_id].blank? ? session[:user_id] : params[:alternative][:user_id]
    @rosa.application_name = params[:alternative][:application_name]
    @rosa.application_description = params[:alternative][:application_description]
    @rosa.ruby_version = params[:alternative][:ruby_version]
    @rosa.rails_version = params[:alternative][:rails_version]
    @rosa.application_ide = params[:alternative][:application_ide]
    @rosa.application_status = params[:application_status].to_i
    @rosa.source_url = session[:source_url]
    @rosa.file_name = ''
    @rosa.file_size = ''
    ct = 1
    session[:feature_rows].times do
      @rosafeatures = RosaFeatures.new
      @rosafeatures.record_text = params["rt_#{ct}"]
      @rosafeatures.destroy_feature = params["deo_#{ct}"] ? true : false
      @rosa.features << @rosafeatures
      ct = ct + 1
    end
    @rosa
  end

end
