class ApplicationController < Sinatra::Base

    configure do
        register Sinatra::Reloader
        enable :sessions
    end
    
    set :views, 'app/views'

    get '/' do #DONE
        session.clear
        erb :index
    end

    get '/leaderboard' do #DONE
        erb :leaderboard
    end

    helpers do #DONE
        def logged_in?
            !!current_user
        end
        
        def current_user
            @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
        end
    end







    get '/signup' do #DONE
		if logged_in?
            redirect '/main'
        else
            erb :'/users/signup'
        end
    end

    post "/signup" do #DONE
        username = params[:username]
        password = params[:password]
        
        if username == "" || password == ""
            @message = "Username and password cannot be blank."
            erb :'/users/signup'            
        elsif User.find_by(username: username) != nil
            @message = "User #{username} already exists."
            erb :'/users/signup'       
        else
            user = User.create(:username => username, :password => password, :balance => 100000)
            session[:user_id] = user.id
            redirect '/main'
        end
    end

    post '/login' do #DONE     
        username = params[:username]
        password = params[:password]
        
        @user = User.find_by(:username => params[:username])
		
		if @user && @user.authenticate(params[:password])
          session[:user_id] = @user.id
          redirect '/main'
        end
        
        erb :'users/error'
    end
    
    get '/main' do #DONE
        if logged_in?
            @user = User.find_by(id: session[:user_id])
            erb :'users/main'
        else
            redirect '/'
        end
    end

    get '/logout' do #DONE
        session.clear
        redirect '/'
    end






    get '/quote' do
        if logged_in?
            erb :'/buy_stocks/quote'
        else
            redirect '/'
        end
    end

    post '/quote' do
        @stock = StockQuote.new(params[:symbol].upcase)

        session[:stock] = @stock

        erb :'/buy_stocks/quote'
    end

    post '/purchase' do
        @stock = session[:stock]

        @quantity = params[:quantity]
        @total = (@quantity.to_f * @stock.current_price).round(2)

        session[:quantity] = @quantity
        session[:total] = @total
                
        erb :'/buy_stocks/quote'
    end

    post '/purchase/make' do
        @stock = session[:stock]
        @quantity = session[:quantity]
        @total = session[:total]

        @user = User.find_by(id: session[:user_id])

        if @total > @user.balance
            session.delete(:stock)
            session.delete(:quantity)
            session.delete(:total)

            erb :'/buy_stocks/rejected'
        else
            @user.buy_stock(@stock.ticker, @quantity.to_i, @total.to_f)           
            @user.save
            redirect '/purchase/confirm/page'
        end      
    end

    get '/purchase/confirm/page' do
        if logged_in?
            @stock = session[:stock]
            @quantity = session[:quantity]
            @total = session[:total]
            @user = User.find_by(id: session[:user_id])

            session.delete(:stock)
            session.delete(:quantity)
            session.delete(:total)

            erb :'/buy_stocks/completed'
        else
            redirect '/'
        end        
    end












    get '/sell' do
        if logged_in?
            erb :'/sell_stocks/sell'
        else
            redirect '/'
        end        
    end

    post '/sell' do
        @stock = StockQuote.new(params[:ticker])

        session[:stock] = @stock

        erb :'/sell_stocks/sell'
    end

    post '/sell/make' do
        @stock = session[:stock]

        @quantity = params[:quantity]
        @total = (@quantity.to_f * @stock.current_price).round(2)

        session[:quantity] = @quantity
        session[:total] = @total

        erb :'/sell_stocks/sell'
    end

    post '/sell/confirm' do
        @user = User.find_by(id: session[:user_id])
        @stock = session[:stock]
        @quantity = session[:quantity]
        @total = session[:total]

        @user.buy_stock(@stock.ticker, -@quantity.to_i, -@total.to_f)
        @user.save
        
        redirect '/sell/confirm/page'
    end

    get '/sell/confirm/page' do
        @user = User.find_by(id: session[:user_id])
        @stock = session[:stock]
        @quantity = session[:quantity]
        @total = session[:total]

        session.delete(:stock)
        session.delete(:quantity)
        session.delete(:total)

        erb :'/sell_stocks/completed'
    end
end
