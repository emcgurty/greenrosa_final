# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def add_feature(name)
  link_to_function name do |page|
    page.insert_html :bottom, :feature_rows, :partial => 'feature', :object => Feature.new
  end
end


  def pluralize_without_count(count, noun, text = nil)
    if count != 0
      count == 1 ? "#{noun}#{text}" : "#{noun.pluralize}#{text}"
    end
  end

  def get_application_status(status_number)
    @get_status_text = ""
    CollaboratorMethods.collaborator_value[:application_status].each do |val|
      val.each do |status_string|
        if status_string ==  status_number
          @get_status_text = val[1].to_s
          break
        end
      end
      
    end
    @get_status_text.strip
  end

  def find_element_in_multidimensional_array(this_array, sought_value)

    return_string = 'NA'
    this_array.each do |i_array|
      i_array.each_with_index do |in_array, i_index|
        if in_array ==  sought_value
          return_string = in_array[i_index][1]
        end
      end
    end
    return_string
  end

  
  
  def get_full_name(object)
    fullname = ''
    strmi = object.mi
    if strmi.blank?
      fullname = object.first_name + " " + object.last_name
    else
      fullname = object.first_name + " " + object.mi + " " + object.last_name
    end
    fullname
  end

  def get_organization_url(url)
    html = ''
    org_url = "http://" + url.to_s
    org_url1 = org_url.gsub('.', '(dot)' )
    html << "<a href='#{org_url}'>#{org_url1}</a>"
    html
  end

end
