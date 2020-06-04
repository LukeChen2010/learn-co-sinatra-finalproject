class User < ActiveRecord::Base
    has_many :stocks

    def buy_stock(ticker, quantity, total)
        stock = Stock.find_by(ticker: ticker, user_id: self.id)
    
        if stock == nil
            stock = Stock.create(ticker: ticker, quantity: quantity, total: total, user_id: self.id)     
            self.balance -= total
        else
            stock.quantity += quantity

            if quantity < 0 #selling
                stock.total += stock.total.to_f / stock.quantity.to_f * quantity.to_f
            else 
                stock.total += total
            end

            self.balance -= total

            if stock.quantity == 0
                stock.destroy
            end

            stock.save
        end
    end

    def portfolio_value
        value = self.balance

        stocks = Stock.where(user_id: self.id)

        stocks.each do |x|
            stock = StockQuote.new(x.ticker)
            value += stock.current_price * x.quantity.to_f
        end

        return value
    end
end
