class User < ActiveRecord::Base
    has_many :stocks

    def buy_stock(ticker, quantity, total)
        stock = Person.find_by(ticker: ticker, user_id: self.id)
        if stock == nil
            stock = Stock.create(ticker: ticker, quantity: quantity, total: total, user_id: self.id)     
        else
            stock.quantity += quantity

            if quantity < 0
                stock.total += stock.total / stock.quantity * quantity
            else
                stock.total += total
            end

            if stock.quantity == 0
                @owned_stocks.delete_if {|x| x.ticker == ticker}
            end
        end
    end

    def portfolio_value
        value = @balance

        stock = Stock.where(ticker: ticker, user_id: self.id)

        @owned_stocks.each do |x|
            stock = StockQuote.new(x.ticker)
            value += stock.current_price * x.quantity.to_f
        end

        return value
    end
end
