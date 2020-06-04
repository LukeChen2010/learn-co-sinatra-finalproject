require_relative './config/environment'

namespace :db do

  desc "Migrate the db"
  task :migrate do
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: 'db/final_project.db'
    )
    ActiveRecord::Migration.migrate("db/migrate/")
  end
  
end
