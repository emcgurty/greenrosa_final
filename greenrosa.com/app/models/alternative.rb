class Alternative < ActiveRecord::Base


  attr_accessor :uploaded_zip_file, :repository
  has_many :features
  belongs_to :collaborates
  before_create :uploaded_zip_file

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  alpha_regex = /\A[ a-zA-Z'-]+\z/
  alpha_numeric_regex = /\A[ a-zA-Z0-9@$%^!?.:;'-]+\z/


  validates_presence_of :application_name, :application_description, :ruby_version, :rails_version, :application_ide, :application_status
  validates_format_of :application_status, :with => /[1-9]+/ , :on => :create
  validates_uniqueness_of :application_name, :case_sensitive => false
  

  def validate
    

    self.application_description  = htmlsafe(self.application_description) unless self.application_description.blank?


    self.application_name  = htmlsafe(self.application_name) unless self.application_name.blank?
  
  self.ruby_version  = htmlsafe(self.ruby_version) unless self.ruby_version.blank?
 

   self.rails_version  = htmlsafe(self.rails_version) unless self.rails_version.blank?
  
  self.application_ide  = htmlsafe(self.application_ide) unless self.application_ide.blank?


 
   if source_url.blank? && content_type == 'invalid'
      errors.add(:file_too_large, ":Selected file #{file_name} refused because it is either too large or it is an executable.  Source file must be no more than 500 KB.")
    elsif source_url.blank? && content_type.blank?
      errors.add(:missing_code_source, ":You need to provide either a source file or repository source to contribute as a collaborator.")
    end
    if !(source_url.blank?) && content_type == 'NA' && file_name == 'NA'
      unless url_valid?(source_url)
        errors.add(:source_url, "... URL is not in standard format")
      end
    end
  end

  def htmlsafe(s)

    s = s.to_s
    s.gsub(/[&><]/, '-')
  end

  def url_valid?(url)
    begin
      url = URI.parse(url)
    rescue
      false
    else
      true
    end
    #    url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS)
  end

end
