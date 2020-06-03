require "open-uri"
require "net/http"
require "json"
require "date"
require "bundler/setup"

class StockQuote
    attr_accessor :ticker, :name, :exchange, :finnhubIndustry, :weburl, :company_profile
    attr_accessor :current_price, :previous_close

    def initialize(symbol)
        @company_profile = get_payload("https://finnhub.io/api/v1/stock/profile2?symbol=#{symbol}&token=brbai0nrh5rb7je2n1l0")
        
        if @company_profile == {}
            @ticker = symbol
            return
        end

        @ticker = @company_profile["ticker"] 
        @name = @company_profile["name"]
        @exchange = @company_profile["exchange"]
        @finnhubIndustry = @company_profile["finnhubIndustry"]
        @weburl = @company_profile["weburl"]

        quote = get_payload("https://finnhub.io/api/v1/quote?symbol=#{symbol}&token=brbai0nrh5rb7je2n1l0")
        @previous_close = quote["pc"].to_f
        @current_price = quote["c"].to_f        
    end

    def get_payload(url)
        uri = URI.parse(url)
        response = Net::HTTP.get_response(uri)
        payload = JSON.parse(response.body)
    end
end