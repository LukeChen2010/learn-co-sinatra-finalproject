require_relative '../config/environment'

User.delete_all

user1 = User.create(:username => "user1", :password => "user1", :balance => 100000)

user2 = User.create(:username => "user2", :password => "user2", :balance => 100000)

user3 = User.create(:username => "user3", :password => "user3", :balance => 100000)