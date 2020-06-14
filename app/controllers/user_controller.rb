class UserController < ApplicationController

    get '/signup' do 
        redirect '/main' if logged_in?
    
        erb :'/users/signup'
    end
    
    post "/signup" do 
        username = params[:username]
        password = params[:password]
    
        sanitized_username = username.gsub(/[<>]/, "")
        sanitized_password = password.gsub(/[<>]/, "")
        
        if username == "" || password == ""
            @message = "Username and password cannot be blank."
            erb :'/users/signup' 
        elsif username != sanitized_username || password != sanitized_password  
            @message = "Nice try, sucker!"
            erb :'/users/signup'     
        elsif User.find_by(username: username) != nil
            @message = "User #{username} already exists."
            erb :'/users/signup'       
        else
            user = User.create(:username => username, :password => password, :balance => 100000)
            session[:user_id] = user.id
            redirect '/main'
        end
    end
    
    post '/login' do      
        username = params[:username]
        password = params[:password]
        
        @user = User.find_by(:username => params[:username])
        
        if @user && @user.authenticate(params[:password])
            session[:user_id] = @user.id
            redirect '/main'
        else
            erb :'users/error'
        end    
    end
    
    get '/main' do 
        redirect '/' if !logged_in?
    
        @user = current_user
        erb :'users/main'
    end
    
    get '/logout' do 
        session.clear
        redirect '/'
    end

end