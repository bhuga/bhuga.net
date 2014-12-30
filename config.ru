#\ -p 3000

$:.unshift './lib'
require 'bundler'
Bundler.setup
require 'rack/cors'
require 'sprockets'
require 'asset_helpers'
require 'sass-extensions'
require 'bhuga'
require "pry"


use Rack::Cors do
  allow do
    origins /.*bhuga\.net.*/
    resource "*", :headers => :any, :methods => :get
  end
end

map '/assets' do
  sprockets = Sprockets::Environment.new
  sprockets.append_path 'assets/javascripts'
  sprockets.append_path 'assets/stylesheets'
  Bhuga.set :sprockets, sprockets
  run sprockets
end

run Bhuga
