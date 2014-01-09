Greenrosa::Application.routes.draw do |map|
  
  map.alternative_list 'alternative/list/:id', :controller => "alternative", :action => "list"
  map.alternative_download 'alternative/download/:id', :controller => "alternative", :action => "download"
  map.alternative_view 'alternative/view/:id', :controller => "alternative", :action => "view"
  map.alternative_delete 'alternative/delete/:id', :controller => "alternative", :action => "delete"
  map.alternative_edit 'alternative/edit/:id', :controller => "alternative", :action => "edit"
  map.alternative_search 'alternative/search', :controller => "alternative", :action => "search"
  map.alternative_feature_search 'alternative/feature_search', :controller => "alternative", :action => "feature_search"
  map.alternative_new 'alternative/new', :controller => "alternative", :action => "new"
  map.admin_contact_us 'admin/contact_us', :controller => "admin", :action => "contact_us"
  map.home_show 'home/show', :controller => "home", :action => "show"
  map.home_errorpage 'home/errorpage/:error_msg', :controller => "home", :action => "errorpage"
  map.home_emailsuccess 'home/emailsuccess/:success_msg', :controller => "home", :action => "emailsuccess"
  map.user_show 'user/show', :controller => "user", :action => "show"
  map.user_user_record 'user/new/:id', :controller => "user", :action => "user_record"
  map.user_reset_password 'user/reset_password/:id', :controller => "user", :action => "reset_password"
  map.user_forgot_username 'user/forgot_username', :controller => "user", :action => "forgot_username"
  map.user_forgot_password 'user/forgot_password', :controller => "user", :action => "forgot_password"
  map.user_logout 'user/logout', :controller => "user", :action => "logout"
  map.user_update_user_information 'user/update_user_information/:id', :controller => "user", :action => "update_user_information"
  map.collaborator_search_by_criteria 'collaborator/search_by_criteria', :controller => "collaborator", :action => "search_by_criteria"
  map.activate 'user/activate/:activation_code', :controller => "user", :action => "activate"
  map.root :controller => "home", :action => 'home'
  map.connect ':controller/:action/:id'

end
