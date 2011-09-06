require 'yaml'
require 'rdiscount'

class Post
  attr_accessor :meta, :body

  def initialize(file)
    contents = IO.read(file)
    if contents =~ /^(---\s*\n.*)\n---\s*\n(.*)/m
      @meta = YAML.load($1)
      @body = $2
    else
      @meta = {}
      @body = contents
    end
    if @meta[:slug] =~ /(\d+)\/(\d+)\/(.*)/
      @meta[:year] = $1
      @meta[:month] = $2
      @meta[:slug] = $3
    end
  end

  def self.all
    Dir.glob(self.directory + '/*.md').map { |file| self.new(file) }.sort.reverse
  end

  def title
    meta[:title]
  end

  def <=>(other)
    @meta[:date] <=> other.meta[:date]
  end

  def body
    @parsed_body ||= RDiscount.new(@body).to_html
  end

  def disqus_identifier
    @meta.has_key?(:drupal_id) ? "node/#{@meta[:drupal_id]}" : @meta[:slug]
  end

  def first_paragraph
    body.split(/<\/p>/).first
  end

  def method_missing(method, *args)
    meta.has_key?(method) ? meta[method] : super
  end

  def created
    Time.at(@meta[:date].to_i).strftime('%b %d, %Y')
  end
end

class BookReview < Post
  def self.directory
    'book_reviews'
  end
end

class BlogPost < Post
  def self.directory
    'blog_posts'
  end
end

