--- 
:drupal_id: 60
:date: 1270273921
:type: story
:title: Running RSpec on Heroku
:format_id: 4
:format: Markdown
:slug: 2010/04/running-rspec-heroku
---
Recently, while working on [my rdf-do gem](http://github.com/bhuga/rdf-do), a simple SQL backend for [RDF.rb](http://rdf.rubyforge.org), I wanted to make sure it worked on Heroku.  Easier said than done--Heroku demands a webapp, and RSpec hates that.  But I fought it and fixed it.

First, in the root of your gem repository, add a Gemfile and a config.ru (examples are at the end).  Then commit them, heroku create, and push.  You'll need to push from master initially; heroku won't let you push to master from another branch until it already exists:

    $ git commit -m "heroku stuff" Gemfile config.ru
    $ heroku create mygemname
    $ git push heroku master

Now, we don't want this Heroku stuff cluttering up our repository in general.  So make a heroku branch and clean up your master.  You'll never need to push the Heroku branch to github or anything.

    $ git branch heroku
    $ git reset --hard HEAD^1

You can update your heroku branch, and your app, whenever it is you want to test, by merging master and pushing your heroku branch to Heroku's master branch:

    $ git checkout heroku
    $ git merge master
    $ git push heroku heroku:master

Poof! Now you're running your config.ru application.  In my case, I wanted to run RSpec and get the html output.  The config.ru I am using for my RDF::DataObjects gem is:

    # sample heroku rackup
    
    $:.unshift(Dir.glob("./.bundle/gems/bundler/gems/rdf-spec*gemspec*/lib").first)
    
    require 'spec'
    
    app = proc do |env|
    
        io = StringIO.new
      
        basename = File.basename(env['REQUEST_PATH'])
        if basename.empty?
          files = Dir.glob(File.dirname(__FILE__) + '/spec/*.spec')
        else
          files = ['spec/' + basename + ".spec"] unless basename =~ /spec$/
        end
    
        options = ['--format','html',files].flatten
        puts "I couldn't find #{options.last}" unless File.exists?(options.last)
    
        parser = ::Spec::Runner::OptionParser.new(io, io)
        parser.order!(options)
        opts = parser.options
        ::Spec::Runner.use opts
        opts.run_examples
    
      [ 200, {'Content-Type' => 'text/html'}, io.string ]
    end
    
    
    run app
 
There's nothing special about the gemfile:

    # Gemfile
    source 'http://rubygems.org'
    gem 'rdf-spec'
    gem 'pg'
    gem 'sqlite3'
    gem 'data_objects'
    gem 'do_sqlite3'
    gem 'do_postgres'
    gem 'rdf'
    gem 'rspec'


This will run any test at appname.heroku.com/spec-file-name.  For example, my rdf-do gem has a spec/sqlite3.spec file.  You can see the output at <http://rdfdo.heroku.com/sqlite3>, or below, where a screenshot is perhaps embedded; I'm not a specialist here.

<div class="thumbnail"><a href="http://skitch.com/blavender/n7djw/rspec-results"><img src="http://img.skitch.com/20100403-1jtnh4ujsqk9nc4irbc6wxjs6s.preview.jpg" alt="RSpec results" /></a><br /><span style="font-family: Lucida Grande, Trebuchet, sans-serif, Helvetica, Arial; font-size: 10px; color: #808080">Uploaded with <a href="http://plasq.com/">plasq</a>'s <a href="http://skitch.com">Skitch</a>!</span></div>
