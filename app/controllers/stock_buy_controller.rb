class StockBuyController < ApplicationController

    get '/quote' do
        redirect '/' if !logged_in?

        symbol = params[:symbol]
        redirect "/quote/#{symbol}" if symbol != nil
        
        erb :'/buy_stocks/quote'
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
            if !@user.buy_stock(@ticker, @quantity.to_i, @total.to_f)
                redirect '/'
            else
                erb :'/buy_stocks/completed'
            end            
        end      
    end

end