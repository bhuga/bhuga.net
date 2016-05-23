#!/usr/bin/env ruby

require "bundler/setup"
require_relative "lib/post"
require "pry"

#pry binding

def make_post(bp, dir)
  meta = bp.meta
  filename = "#{dir}/#{meta[:date].strftime("%Y-%m-%d")}-#{meta[:slug]}.md"
  front_matter = {}
  front_matter[:layout] = "post"
  front_matter[:title] = "\"#{bp.meta[:title]}\""
  front_matter[:author] = "\"#{bp.meta[:author]}\"" if bp.meta[:author]

  header = front_matter.map { |k, v| "#{k}: #{v}" }.join("\n")
  body = bp.send :instance_variable_get, :@body
  body.gsub!("<!--break-->","")
  output = <<EOS
---
#{header}
---
#{body}
EOS

IO.write(filename, output)
end

BlogPost.all.each do |bp|
  make_post(bp, "_posts")
end

BookReview.all.each do |bp|
  make_post(bp, "_book_reviews")
end
