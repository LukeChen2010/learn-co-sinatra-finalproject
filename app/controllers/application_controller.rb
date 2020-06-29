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
        @sorted_users = User.all.sort {|a,b| a.calc_portfolio_value <=> b.calc_portfolio_value}.reverse 

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
