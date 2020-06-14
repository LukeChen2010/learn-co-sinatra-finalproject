class StockBuyController < ApplicationController

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