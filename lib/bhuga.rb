require 'haml'
require 'sinatra'
require 'coffee-script'
require 'time'
require_relative './post.rb'
# sets BASE_HOST
load 'env.rb' if File.exists? 'env.rb'
raise Exception, "I need an ENV['BASE_HOST'] plz" unless defined?(BASE_HOST)

class Bhuga < Sinatra::Application

  set :views, './views'
  set :public, './public'

  def feed_for(posts)
    builder do |xml|
      xml.instruct! :xml, :version => '1.0'
      xml.rss :version => '2.0' do
        xml.channel do
          xml.title 'BHUGA WOOGA'
          xml.description 'Blog Posts'
          xml.link 'http://bhuga.net'
          posts.each do |post|
            xml.item do
              url = BASE_HOST + '/' + post.slug
              xml.title post.title
              xml.link url
              description = post.meta.has_key?(:author) ? "By #{post.author}<br/>" : ""
              xml.description(description + post.body)
              xml.pubDate post.date.rfc2822
              xml.guid url
            end
          end
        end
      end
    end
  end

  get '/' do
    @blog_posts = BlogPost.all
    @book_reviews = BookReview.all
    haml :index
  end

  get '/feed' do
    feed_for(BlogPost.all.sort.reverse.slice(0,10))
  end

  # old drupal location
  get '/rss.xml' do
    call env.merge("PATH_INFO" => '/feed')
  end

  # old drupal location
  get '/books-feed' do
    feed_for(BookReview.all.sort.reverse.slice(0,10))
  end

  get '/books-rss.xml' do
    call env.merge("PATH_INFO" => '/books-feed')
  end

  # keep publishing at some legacy drupal URLs, too.
  get '/:year/:month/:slug' do
    # note that we do not care about legacy URLs enough to only respond on the correct one...
    call env.merge("PATH_INFO" => '/' + params[:slug])
  end

  [:cv, :about, :acknowledgements].each do |page|
    get '/' + page.to_s do
      haml page
    end
  end

  get '/books' do
    @book_reviews = BookReview.all.sort.reverse
    haml :books
  end

  get '/blog' do
    @posts = BlogPost.all.sort.reverse
    haml :blog
  end

  get '/css/bhuga.css' do
    scss :'css/bhuga'
  end

  %w{bhuga vibrate explosion swim}.each do |js|
    get '/js/' + js + '.js' do
      file = "js/#{js}".to_sym
      coffee file
    end
  end

  not_found do
    haml :'404'
  end

  get '/:slug' do
    @posts = BlogPost.all + BookReview.all
    @post = @posts.find { |post| post.slug =~ /#{params[:slug]}/ }
    @post.nil? ? not_found : (haml :post)
  end

  helpers do
    def content_for(key, &block)
      @content ||= {}
      @content[key] = capture_haml(&block)
    end
    def content(key)
      @content && @content[key]
    end
  end

end
