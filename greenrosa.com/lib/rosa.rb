class Rosa
  attr_accessor :features, :id, :user_id, :application_name, :application_description, 
    :ruby_version, :rails_version, :application_ide, :application_status,
    :source_url, :remote_ip, :file_name, :file_size
    
  def initialize()
    @features = Array.new
  end

end

