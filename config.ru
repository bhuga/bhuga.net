#\ -p 3000

$:.unshift './lib'
require 'bundler'
Bundler.setup
require 'sprockets'

require 'bhuga'
map '/assets' do
  sprockets = Sprockets::Environment.new
  sprockets.append_path 'assets/javascripts'
  sprockets.append_path 'assets/stylesheets'
  Bhuga.set :sprockets, sprockets
  run sprockets
end

run Bhuga
