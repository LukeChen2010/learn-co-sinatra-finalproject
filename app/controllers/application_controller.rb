require_relative '../models/StockQuote'

class ApplicationController < Sinatra::Base

    configure do
        register Sinatra::Reloader
        enable :sessions
    end
    
    set :views, 'app/views'

    get '/' do
        if session[:user] == nil
            @user = TestUser.new("user1", "user1", 100000)  
            session[:user] = @user
        else
            @user = session[:user]
        end

        erb :index
    end

    get '/quote' do
        @user = session[:user]
        erb :quote
    end

    post '/quote' do
        @user = session[:user]
        @stock = StockQuote.new(params[:symbol].upcase)
        session[:stock] = @stock
        @quantity = params[:quantity]
        erb :quote
    end

    post '/purchase' do
        @user = session[:user]
        @stock = session[:stock]
        @quantity = params[:quantity]
        @total = (@quantity.to_f * @stock.current_price).round(2)
        session[:quantity] = @quantity
        session[:total] = @total
        erb :quote
    end

    post '/purchase/make' do
        @stock = session[:stock]
        @quantity = session[:quantity]
        @total = session[:total]
        @user = session[:user]

        if @total > @user.balance
            erb :rejected
        else
            @user.buy_stock(@stock.ticker, @quantity.to_i, @total.to_f)
            @user.balance -= @total
            erb :buy_completed
        end
    end

    get '/sell' do
        @user = session[:user]
        erb :sell
    end

    post '/sell' do
        @user = session[:user]
        @selected_ticker = params[:ticker]
        @stock = StockQuote.new(@selected_ticker)
        session[:ticker] = @selected_ticker
        session[:stock] = @stock
        erb :sell
    end

    post '/sell/make' do
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
        @user = session[:user]
        @stock = session[:stock]
        @quantity = session[:quantity]
        @total = session[:total]

        @user.buy_stock(@stock.ticker, -@quantity.to_i, -@total.to_f)
        @user.balance += @total
        erb :sell_completed
    end

end
