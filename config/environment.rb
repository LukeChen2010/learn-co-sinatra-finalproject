require 'rubygems'
require 'active_record'
require 'sqlite3'
require 'sinatra'
require 'sinatra/reloader'
require "open-uri"
require "net/http"
require "json"
require "date"
require "bundler/setup"

require_relative '../app/controllers/application_controller'
require_relative '../app/controllers/user_controller'
require_relative '../app/controllers/stock_buy_controller'
require_relative '../app/controllers/stock_sell_controller'
require_relative '../app/models/StockQuote'
require_relative '../app/models/user'
require_relative '../app/models/stock'

ENV['SINATRA_ENV'] ||= "development"

require 'bundler/setup'
Bundler.require(:default, ENV['SINATRA_ENV'])

def fi_check_migration
  begin
    ActiveRecord::Migration.check_pending!
  rescue ActiveRecord::PendingMigrationError
    raise ActiveRecord::PendingMigrationError.new <<-EX_MSG
Migrations are pending. To resolve this issue, run:
      rake db:migrate SINATRA_ENV=test
EX_MSG
  end
end

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "db/#{ENV['SINATRA_ENV']}.sqlite"
)

class ToCurrency
    def self.format(num)
        return "$" << sprintf("%.2f", num).reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
    end
end