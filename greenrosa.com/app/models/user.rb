require 'digest/sha1'
class User < ActiveRecord::Base

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  name_alpha_regex = /\A[ a-zA-Z'-]+\z/
  alpha_numeric_regex = /\A[0-9 a-zA-Z:;.,!?'-]+\z/
  alpha_numeric_regex_msg = "must be alphanumeric characters with typical writing punctuation."
  alpha_numeric_regex = /\A[ a-zA-Z0-9!?.:;'-]+\z/


  belongs_to :collaborates
  set_primary_key :user_id
  attr_accessor :password, :password_confirmation
  attr_accessible :username, :email, :display_name, :remote_ip,
    :first_name, :last_name, :mi,
    :user_id,:user_alias,
    :password, :password_confirmation,
    :salt, :crypted_password,  :reset_code
  before_save :encrypt_password
  before_create :make_activation_code
  validates_presence_of  :username,:password, :password_confirmation, :first_name, :last_name, :user_alias, :email, :on => :create
  validates_uniqueness_of :username, :on => :create,:if => :username, :case_sensitive => true
  validates_length_of :password, :if => :password, :in => 6..16, :message => "must be between 6 and 16 characters"
  validates_confirmation_of :password ,:if => :password, :message => "password and re-entered password must match."
  validates_format_of :first_name, :on => :create, :if => :first_name, :with => alpha_numeric_regex, :message => alpha_numeric_regex_msg
  validates_format_of :mi, :allow_blank => true, :if => :mi, :on => :create, :with => alpha_numeric_regex, :message => alpha_numeric_regex_msg
  validates_format_of :last_name, :on => :create, :if => :last_name, :with => alpha_numeric_regex, :message => alpha_numeric_regex_msg
  validates_length_of :user_alias, :if => :user_alias, :in => 6..16, :message => "must be between 6 and 16 characters"
  validates_uniqueness_of :email, :on => :create,:if => :email, :case_sensitive => true
  validates_format_of :email, :with => email_regex, :if => :email, :on_=> :create, :message => "improperly formatted"
  # Activates the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    if save(:validate => false)
      return true
    else 
      return false
    end
  end

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  # Authenticates a user by their username and unencrypted password. Returns the user or nil.
  def self.authenticate(username, password)
    u = find :first, :conditions => ['username = ? and activated_at IS NOT NULL', username]
    # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering user between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token = encrypt("#{email}--#{remember_token_expires_at}")
    save(:validate => false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token = nil
    save(:validate => false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    return @activated
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token = nil
    save(:validate => false)
  end

  #reset methods
  def create_reset_code(which)
    @reset = true
    self.attributes = {:reset_code => Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )}
    if which == 'password'
      @reset_password = true
    else
      @get_username = true
    end
    save(:validate => false)
  end

  def recently_reset?
    @reset
  end

  def recently_password_reset?
    @reset_password
  end

  def recently_username_get?
    @get_username
  end
  
  def delete_reset_code
    self.attributes = {:reset_code => nil}
    save(:validate => false)
  end

  protected
  # before filter
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{username}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def password_required?
    crypted_password.blank? || !password.blank?
  end

  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

end