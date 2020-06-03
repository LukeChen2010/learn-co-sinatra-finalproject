class Helpers
    def self.current_user(session)
      @user = User.find(session[:user_id])
      return @user
    end
    
    def self.is_logged_in?(session)
      return session[:user_id] != nil
    end
end