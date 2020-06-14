require_relative './config/environment'

use Rack::MethodOverride
use StockBuyController
use StockSellController
use UserController
run ApplicationController