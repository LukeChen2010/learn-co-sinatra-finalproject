require_relative './config/environment'

use Rack::MethodOverride
use StockController
use UserController
run ApplicationController