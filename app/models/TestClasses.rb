class TestUser
    attr_accessor :name, :password, :balance, :owned_stocks
    @@all = []

    def initialize(name, password, balance)
        @name = name
        @password = password
        @balance = balance
        @owned_stocks = {}
        
        @@all << self
    end

    def self.all
        return @@all
    end

    def buy_stock(ticker, quantity, total)
        if @owned_stocks[ticker] == nil
            @owned_stocks[ticker] = [quantity, total]            
        else
            @owned_stocks[ticker][0] += quantity
            @owned_stocks[ticker][1] += total
            if @owned_stocks[ticker][0] == 0
                @owned_stocks.delete(ticker)
            end
        end
    end

    def portfolio_value
        value = @balance

        @owned_stocks.each do |ticker, quantity|
            stock = StockQuote.new(ticker)
            value += stock.current_price * quantity[0].to_f
        end

        return value
    end
end