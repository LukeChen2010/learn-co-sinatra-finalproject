require 'rubygems'
require 'active_record'
require 'sqlite3'
require 'sinatra'
require 'sinatra/reloader'
require 'rake'
require "open-uri"
require "net/http"
require "json"
require "date"
require "bundler/setup"

require_relative '../app/controllers/application_controller'
require_relative '../app/models/StockQuote'
require_relative '../app/models/TestClasses'

ActiveRecord::Base.establish_connection(
    adapter: 'sqlite3',
    database: 'db/final_project.db'
)

class ToCurrency
    def self.format(num)
        return "$" << sprintf("%.2f", num).reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
    end
end