require 'haml'
require 'sinatra'
require 'coffee-script'
require_relative './post.rb'

class Bhuga < Sinatra::Application

  set :views, './views'
  set :public, './public'

  get '/' do
    @blog_posts = BlogPost.all
    @book_reviews = BookReview.all
    haml :index
  end

  get '/feed' do
  end
  
  # old drupal location
  get '/rss.xml' do
  end

  get '/books' do
  end

  # old drupal location
  get '/books-feed' do
  end

  # keep publishing at some legacy drupal URLs, too.
  get '/:year/:month/:slug' do
  end

  get '/:slug' do
    @posts = BlogPost.all + BookReview.all
    @post = @posts.find { |post| post.slug =~ /#{params[:slug]}/ }
    @post.nil? ? not_found : (haml :post)
  end

  get '/css/bhuga.css' do
    scss :'css/bhuga'
  end

  get '/js/bhuga.js' do
    coffee :'js/bhuga'
  end
  
  get '/js/vibrate.js' do
    coffee :'js/vibrate'
  end
  
  not_found do
    haml :'404'
  end

end
