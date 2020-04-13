#require libraries
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require './main'
require './Student'


DataMapper.setup(:default, ENV['DATABASE_URL']|| "sqlite3://#{Dir.pwd}/development.db")  # connecting to database
configure do
  enable :sessions
  set :username, "admin"
  set :password, "admin"
end

class Comment   # define class which will be use in databse to create table and property as columns
  include DataMapper::Resource
  property :cid, Serial
  property :comment, String
  property :sname, String
  property :created_at, DateTime
  property :updated_at, DateTime
end

DataMapper.finalize  # validity/integrity checking, initialize all properties.
#DataMapper.auto_migrate!
Comment.auto_upgrade!  # upgrade table

get '/comments' do
  @comments = Comment.all
  if session[:admin] == true
    erb :comments, :layout => :layout1
  else
    erb :comments
  end
end

#Route for the new student form
get '/comments/new' do
  halt(401, 'Not Authorized') unless session[:admin]
  @comment = Comment.new
  erb :new_comment, :layout => :layout1
end

#Shows a single student
get '/comments/:cid' do
  @comment = Comment.get(params[:cid])
  erb :show_comment, :layout => :layout1
end

#Route for the form to edit a single student
get '/comments/:cid/edit' do
  halt(401, 'Not Authorized') unless session[:admin]
  @comment = Comment.get(params[:cid])
  erb :edit_comment, :layout => :layout1
end

#Creates new comment
post '/comments' do
  halt(401, 'Not Authorized') unless session[:admin]
  @comment = Comment.create(params[:comment])
  redirect to('/comments')
end

#Edits a single student
put '/comments/:cid' do
  halt(401, 'Not Authorized') unless session[:admin]
  @comment = Comment.get(params[:cid])
  @comment.update(params[:comment])
  redirect to("/comments/#{@comment.cid}")
end

#Deletes a single student
delete '/comments/:cid' do
  halt(401, 'Not Authorized') unless session[:admin]
  Comment.get(params[:cid]).destroy
  redirect to('/comments')
end
