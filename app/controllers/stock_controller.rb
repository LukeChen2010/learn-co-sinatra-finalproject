class StockController < ApplicationController

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