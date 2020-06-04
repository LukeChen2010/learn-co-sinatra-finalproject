require_relative '../models/StockQuote'

class ApplicationController < Sinatra::Base

    configure do
        register Sinatra::Reloader
        enable :sessions
    end
    
    set :views, 'app/views'

    get '/' do
        session.clear
        erb :index
    end

    post '/login' do     
        username = params[:username]
        password = params[:password]
        
        @user = User.find_by(:username => username, :password => password)
        
        if @user != nil
          session[:user] = @user
          redirect '/main'
        end
        
        erb :error
    end

    get '/main' do
        erb :index if session[:user] == nil

        @user = session[:user]
        erb :main
    end

    get '/quote' do
        erb :index if session[:user] == nil

        @user = session[:user]
        erb :quote
    end

    post '/quote' do
        erb :index if session[:user] == nil

        @user = session[:user]
        @stock = StockQuote.new(params[:symbol].upcase)
        session[:stock] = @stock
        @quantity = params[:quantity]
        erb :quote
    end

    post '/purchase' do
        erb :index if session[:user] == nil

        @user = session[:user]
        @stock = session[:stock]
        @quantity = params[:quantity]
        @total = (@quantity.to_f * @stock.current_price).round(2)
        session[:quantity] = @quantity
        session[:total] = @total
        erb :quote
    end

    post '/purchase/make' do
        erb :index if session[:user] == nil

        @stock = session[:stock]
        @quantity = session[:quantity]
        @total = session[:total]
        @user = session[:user]

        if @total > @user.balance
            erb :rejected
        else
            @user.buy_stock(@stock.ticker, @quantity.to_i, @total.to_f)           
            @user.save
            erb :buy_completed
        end
    end

    get '/sell' do
        erb :index if session[:user] == nil

        @user = session[:user]
        erb :sell
    end

    post '/sell' do
        erb :index if session[:user] == nil

        @user = session[:user]
        @selected_ticker = params[:ticker]
        @stock = StockQuote.new(@selected_ticker)
        session[:ticker] = @selected_ticker
        session[:stock] = @stock
        erb :sell
    end

    post '/sell/make' do
        erb :index if session[:user] == nil

        @selected_ticker = session[:ticker]
        @stock = session[:stock]
        @user = session[:user]
        @quantity = params[:quantity]

        @total = (@quantity.to_f * @stock.current_price).round(2)

        session[:quantity] = @quantity
        session[:total] = @total

        erb :sell
    end

    post '/sell/confirm' do
        erb :index if session[:user] == nil
        
        @user = session[:user]
        @stock = session[:stock]
        @quantity = session[:quantity]
        @total = session[:total]

        @user.buy_stock(@stock.ticker, -@quantity.to_i, -@total.to_f)
        @user.save
        erb :sell_completed
    end

end
