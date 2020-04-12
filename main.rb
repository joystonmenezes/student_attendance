require 'sinatra'
require 'sass'
require './Student'
require './Comment'
require 'sinatra/reloader' if development?  #check environment variable and decide if the environment is “development” or “production”

#enable :sessions
configure :production do
	DataMapper.setup(:default,ENV['DATABASE_URL']|| "sqlite3://#{Dir.pwd}/development.db")
end

configure :development do
	DataMapper.setup(:default,ENV['DATABASE_URL']|| "sqlite3://#{Dir.pwd}/development.db")
end

get('/style.css'){ scss :style }  #include css file

get '/' do
  	if session[:admin] == true  # check if it is a authorized user or not
		erb :home, :layout => :layout1
	else
		erb :home
	end
end

get '/about' do
 	@title = "All About This Website"
  	if session[:admin] == true
		erb :about, :layout => :layout1
	else
		erb :about
	end
end

get '/contact' do
	if session[:admin] == true
		erb :contact, :layout => :layout1
	else
		erb :contact
	end
end

get '/video' do
	if session[:admin] == true
		erb :video, :layout => :layout1
	else
		erb :video
	end
end



