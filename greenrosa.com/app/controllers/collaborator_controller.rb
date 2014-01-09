class CollaboratorController < ApplicationController

 def search_by_criteria
   session[:search_rows] = nil
 end

end
