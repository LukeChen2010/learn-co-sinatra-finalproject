class TestUser
    attr_accessor :name, :password, :balance, :owned_stocks
    @@all = []

    def initialize(name, password, balance)
        @name = name
        @password = password
        @balance = balance
        @owned_stocks = []
        
        @@all << self
    end

    def self.all
        return @@all
    end

    def buy_stock(ticker, quantity, total)
        stock = @owned_stocks.find {|x| x.ticker == ticker}
        if stock == nil
            stock = TestStock.new(ticker, quantity, total)
            @owned_stocks << stock        
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

        @owned_stocks.each do |x|
            stock = StockQuote.new(x.ticker)
            value += stock.current_price * x.quantity.to_f
        end

        return value
    end
end

class TestStock
    attr_accessor :ticker, :quantity, :total

    def initialize(ticker, quantity, total)
        @ticker = ticker
        @quantity = quantity
        @total = total
    end
end
