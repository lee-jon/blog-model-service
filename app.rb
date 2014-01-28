require 'bundler'
Bundler.require

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite")

class Post
  include DataMapper::Resource

  property :id, Serial, :key => true
  property :created_at, DateTime
  property :title,      String, :length => 255
  property :author,     String, :length => 255
  property :content,    Text,   :lazy => false
end

DataMapper.finalize
DataMapper.auto_upgrade!

# PUBLISH SERVICE README
get '/' do
  send_file './README.md'
end

# All the things!
get '/blog_post' do
  content_type :json
  @post = Post.all(:order => :created_at.desc)
  @post.to_json
end

# CREATE
post '/blog_post' do
  content_type :json

  @post = Post.new(params)

  if @post.save
    @post.to_json
  else
    halt 500
  end
end

# READ
get '/blog_post/:id' do
  content_type :json
  @post = Post.get(params[:id])

  if @post
    @post.to_json
  else
    halt 404
  end
end

# UPDATE
put '/blog_post/:id' do
  content_type :json

  @post = Post.get(params[:id])
  @post.update(params)

  if @post.save
    @thing.to_json
  else
    halt 500
  end
end

# DELETE
delete '/blog_post/:id/delete' do
  content_type :json
  @post = Post.get(params[:id])

  if @post.destroy
    {:success => "ok"}.to_json
  else
    halt 500
  end
end

# BASIC INTERFACE
get '/interface' do
  send_file './interface/index.html'
end

# Setup test data
if Post.count == 0
  Post.create(:title => "Sample blog post",
              :content => "Lalalalal",
              :author => "lee-jon")
end
