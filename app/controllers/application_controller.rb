class ApplicationController < Sinatra::Base

    configure do
        register Sinatra::Reloader
        enable :sessions
        set :session_secret, "tRyT0gu3ssThIsLm@0"
        set :views, 'app/views'
    end  

    get '/' do 
        session.clear
        erb :index
    end
    
    get '/leaderboard' do 
        @i = 1
        users_hash = {}

        User.all.each do |x|
            users_hash[x.id] = x.portfolio_value
        end

        @sorted_users = users_hash.sort_by {|id, value| value}.reverse

        erb :leaderboard
    end

    helpers do 
        def logged_in?
            !!current_user
        end
        
        def current_user
            @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
        end
    end

end
