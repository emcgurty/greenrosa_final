class UserObserver < ActiveRecord::Observer
  
  observe :user

  def before_create(user)
    #user.user_id = UUIDTools::UUID.timestamp_create().to_s
    user.user_id = get_random
  end

  def after_create(user)
    Notifier.signup_notification(user).deliver
  end

  def after_save(user)

    Notifier.activation(user).deliver if user.recently_activated?
    #Notifier.deliver_reset_password_notification(user) if user.recently_reset? && user.recently_password_reset?
    #Notifier.deliver_get_username_notification(user) if user.recently_reset? && user.recently_username_get?
  end


  def get_random
    length = 36
    characters = ('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a

    @password = SecureRandom.random_bytes(length).each_char.map do |char|
      characters[(char.ord % characters.length)]
    end.join
    @password
  end


end
