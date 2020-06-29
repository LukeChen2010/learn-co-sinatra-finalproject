class User < ActiveRecord::Base
    attr_accessor :portfolio_value
    has_secure_password
    has_many :stocks

    def buy_stock(ticker, quantity, total)
        stock = Stock.find_by(ticker: ticker, user_id: self.id)

        if quantity < 0
            return false
        end
        
        if stock == nil
            stock = Stock.create(ticker: ticker, quantity: 0, total: 0, user_id: self.id)     
        end

        stock.total += total
        stock.quantity += quantity
        self.balance -= total

        stock.save
        self.save

        return true
    end

    def sell_stock(ticker, quantity, total)
        stock = Stock.find_by(ticker: ticker, user_id: self.id)

        if stock == nil || stock.quantity < quantity || quantity < 0
            return false
        end          

        stock.total -= (stock.total.to_f/stock.quantity.to_f) * quantity.to_f
        stock.quantity -= quantity
        self.balance += total

        stock.save
        self.save

        if stock.quantity == 0
            stock.destroy
        end

        return true
    end

    def calc_portfolio_value
        value = self.balance

        stocks = Stock.where(user_id: self.id)

        stocks.each do |x|
            stock = StockQuote.new(x.ticker)
            value += stock.current_price * x.quantity.to_f
        end

        self.portfolio_value = value
        return value
    end
end
