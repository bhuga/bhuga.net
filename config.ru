#\ -p 3000

$:.unshift './lib'
require 'bundler'
Bundler.setup
require 'sprockets'

map '/assets' do
  environment = Sprockets::Environment.new
  environment.append_path 'assets/javascripts'
  environment.append_path 'assets/stylesheets'
  run environment
end

require 'bhuga'
run Bhuga
