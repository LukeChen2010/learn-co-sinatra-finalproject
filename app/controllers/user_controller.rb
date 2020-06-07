class UserController < Sinatra::Base

    configure do
        register Sinatra::Reloader
        enable :sessions
    end

    
end