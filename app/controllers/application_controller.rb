class ApplicationController < Sinatra::Base

    configure do
        register Sinatra::Reloader
        enable :sessions
        set :session_secret, "tRyT0gu3ssThIsLm@0"
    end
    
    set :views, 'app/views'

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

#RESTFUL
#Session secret
#Not use sessions to pass info
#Eliminate logic in views

##################################################################################

#OK
get '/signup' do 
    redirect '/main' if !logged_in?

    erb :'/users/signup'
end

#OK
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


#OK
post '/login' do      
    username = params[:username]
    password = params[:password]
    
    @user = User.find_by(:username => params[:username])
    
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect '/main'
    end
    
    erb :'users/error'
end

#OK
get '/main' do 
    redirect '/' if !logged_in?

    @user = User.find_by(id: session[:user_id])
    erb :'users/main'
end

#OK
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

        if symbol == nil
            redirect '/quote'
        else
            redirect "/quote/#{symbol}"   
        end    
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

        @user = User.find_by(id: session[:user_id])

        if @total > @user.balance
            erb :'/buy_stocks/rejected'
        else
            if !@user.buy_stock(@ticker, @quantity.to_i, @total.to_f)
                redirect '/'
            else
                erb :'/buy_stocks/completed'
            end            
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

        if !@user.sell_stock(@stock.ticker, @quantity.to_i, @total.to_f)
            redirect '/'
        else
            @user.save
        end     
        
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
