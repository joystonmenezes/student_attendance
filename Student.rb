require 'dm-core'
require 'dm-migrations'
require './main'
require './Comment'
require 'mail'


DataMapper.setup(:default, ENV['DATABASE_URL']|| "sqlite3://#{Dir.pwd}/development.db")  # connecting to database
configure do
  enable :sessions
  set :username, "admin"
  set :password, "admin"
end

class Student   #  define class which will be use in databse to create table and property as columns
  include DataMapper::Resource
  property :id, Serial
  property :fname, String
  property :lname, String
  property :gender, String
  property :bdy, Date
  property :add, String
  property :sid, String
  property :email, String

end

DataMapper.finalize  # validity/integrity checking, initialize all properties created above.
Student.auto_upgrade! #upgrade table after adding column


get '/students' do
  @student = Student.all
  if session[:admin] == true
    erb :students, :layout => :layout1
  else
    erb :students
  end
end


get '/login' do
  erb :login
end

post '/login?' do   # validate authentication
  if params[:username] == settings.username && params[:password] == settings.password
      session[:admin] = true
      erb :logged, :layout => :layout1
  else
    erb :login
  end
end

#Route for the new student form
get '/students/new' do
  if session[:admin] == true
    student = Student.new
    erb :new_student, :layout => :layout1
  else
    erb :login
  end
end


#Shows a single student
get '/students/:id' do
  halt(401, 'Access Denied !') unless session[:admin]
  @student = Student.get(params[:id])
  erb :show_student, :layout => :layout1
end

#Route for the form to edit a single student
get '/students/:id/edit' do
  halt(401, 'Access Denied !') unless session[:admin]
  @student = Student.get(params[:id])
  erb :edit_student, :layout => :layout1
end

#Creates new student
post '/students' do
  halt(401, 'Access Denied !') unless session[:admin]
  @student = Student.create(params[:student])
  redirect to('/students')
end

#Edits a single student
put '/students/:id' do
  halt(401, 'Access Denied !') unless session[:admin]
  @student = Student.get(params[:id])
  @student.update(params[:student])
  redirect to("/students/#{@student.id}")
end

#Deletes a single student
delete '/students/:id' do
  halt(401, 'Access Denied !') unless session[:admin]
  Student.get(params[:id]).destroy
  redirect to('/students')
end

get '/logout' do   # sign out from application
  session.clear
  session[:admin] = false
  erb :home, :layout1 => :layout
end
