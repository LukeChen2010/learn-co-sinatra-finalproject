class ApplicationController < Sinatra::Base

    configure do
        register Sinatra::Reloader
        enable :sessions
        set :session_secret, "tRyT0gu3ssThIsLm@0"
        set :views, 'app/views'
    end  

    #OK
    get '/' do 
        session.clear
        erb :index
    end

    #Needs sorting algorithm
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

#RESTFUL
#Session secret
#Not use sessions to pass info
#Eliminate logic in views

##################################################################################

get '/signup' do 
    redirect '/main' if logged_in?

    erb :'/users/signup'
end

post "/signup" do 
    username = params[:username]
    password = params[:password]

    sanitized_username = username.gsub(/[<>]/, "")
    sanitized_password = password.gsub(/[<>]/, "")
    
    if username == "" || password == ""
        @message = "Username and password cannot be blank."
        erb :'/users/signup' 
    elsif username != sanitized_username || password != sanitized_password  
        @message = "Nice try, sucker!"
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

post '/login' do      
    username = params[:username]
    password = params[:password]
    
    @user = User.find_by(:username => params[:username])
    
    if @user && @user.authenticate(params[:password])
        session[:user_id] = @user.id
        redirect '/main'
    else
        erb :'users/error'
    end    
end

get '/main' do 
    redirect '/' if !logged_in?

    @user = current_user
    erb :'users/main'
end

get '/logout' do 
    session.clear
    redirect '/'
end

##########################################################################################

    get '/quote' do
        redirect '/' if !logged_in?
        
        erb :'/buy_stocks/quote'
    end

    get '/quote/symbol' do
        redirect '/' if !logged_in?

        symbol = params[:symbol]
        redirect '/quote' if symbol == nil

        redirect "/quote/#{symbol}"   
    end

    get '/quote/:symbol' do
        redirect '/' if !logged_in?

        @stock = StockQuote.new(params[:symbol].upcase)
        erb :'/buy_stocks/quote'  
    end

    get '/purchase' do
        redirect '/' if !logged_in?

        @ticker = params[:ticker]
        @quantity = params[:quantity] 
        @current_price = params[:current_price] 

        redirect '/quote' if @ticker == nil
        
        @stock = StockQuote.new(@ticker.upcase)            
        @total = (@quantity.to_f * @current_price.to_f).round(2)

        erb :'/buy_stocks/quote'     
    end

    post '/purchase/make' do
        @ticker = params[:ticker]
        @quantity = params[:quantity]
        @total = params[:total].to_f
        @user = current_user

        if @total > current_user.balance
            erb :'/buy_stocks/rejected'
        else
            #Added back-end input validation
            if !@user.buy_stock(@ticker, @quantity.to_i, @total.to_f)
                redirect '/'
            else
                erb :'/buy_stocks/completed'
            end            
        end      
    end

##########################################################################################

    get '/sell' do
        redirect '/' if !logged_in?

        @stocks = Stock.where(user_id: current_user.id)
        erb :'/sell_stocks/sell'
    end

    get '/sell/select' do
        redirect '/' if !logged_in?

        @ticker = params[:ticker]
        @price = params["price/#{@ticker}"]
        redirect '/sell' if @ticker == nil

        @stocks = Stock.where(user_id: current_user.id)
        @stock = StockQuote.new(@ticker)
        @owned_stock = Stock.find_by(ticker: @ticker, user_id: current_user.id)

        erb :'/sell_stocks/sell'
    end

    get '/sell/make' do
        redirect '/' if !logged_in?

        @ticker = params[:ticker]
        @price = params[:price]
        @quantity = params[:quantity]
        redirect '/sell' if @ticker == nil
        
        @stocks = Stock.where(user_id: current_user.id)
        @stock = StockQuote.new(@ticker)
        @owned_stock = Stock.find_by(ticker: @ticker, user_id: current_user.id)       
        @total = (@quantity.to_f * @price.to_f).round(2)

        erb :'/sell_stocks/sell'
    end

    post '/sell/confirm' do
        @ticker = params[:ticker]
        @price = params[:price]
        @quantity = params[:quantity]
        @total = params[:total]
        @user = current_user

        #Added backend input validation
        if !@user.sell_stock(@ticker, @quantity.to_i, @total.to_f)
            redirect '/'
        else
            erb :'/sell_stocks/completed'
        end          
    end
    
end
