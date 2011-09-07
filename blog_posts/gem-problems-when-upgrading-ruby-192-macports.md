--- 
:drupal_id: 76
:date: 1282943614
:type: story
:title: Gem problems when upgrading to Ruby 1.9.2 with MacPorts
:format_id: 4
:format: Markdown
:slug: 2010/08/gem-problems-when-upgrading-ruby-192-macports
---
If you for any reason have a recompile-the-world moment in MacPorts, you may notice that the `ruby19` port has been upgraded to Ruby 1.9.2.  Ruby 1.9.2 includes Rubygems by default, and any existing Rubygems versions will cause problems.  There's a related discussion at <http://redmine.ruby-lang.org/issues/show/3607>, but it's not really going to help if you just want it to work.

So if, after updating to Ruby 1.9.2, you see this:

    ben-2:logs ben$ gem1.9
    /opt/local/lib/ruby1.9/site_ruby/1.9.1/rubygems/source_index.rb:68:in `installed_spec_directories': undefined method `path' for Gem:Module (NoMethodError)
    from /opt/local/lib/ruby1.9/site_ruby/1.9.1/rubygems/source_index.rb:58:in `from_installed_gems'
    from /opt/local/lib/ruby1.9/site_ruby/1.9.1/rubygems.rb:881:in `source_index'
    from /opt/local/lib/ruby1.9/site_ruby/1.9.1/rubygems/gem_path_searcher.rb:81:in `init_gemspecs'
    from /opt/local/lib/ruby1.9/site_ruby/1.9.1/rubygems/gem_path_searcher.rb:13:in `initialize'
    from /opt/local/lib/ruby1.9/site_ruby/1.9.1/rubygems.rb:839:in `new'
    from /opt/local/lib/ruby1.9/site_ruby/1.9.1/rubygems.rb:839:in `block in searcher'
    from <internal:prelude>:10:in `synchronize'
    from /opt/local/lib/ruby1.9/site_ruby/1.9.1/rubygems.rb:838:in `searcher'
    from /opt/local/lib/ruby1.9/site_ruby/1.9.1/rubygems.rb:478:in `find_files'
    from /opt/local/lib/ruby1.9/site_ruby/1.9.1/rubygems.rb:1103:in `<top (required)>'
    from <internal:lib/rubygems/custom_require>:29:in `require'
    from <internal:lib/rubygems/custom_require>:29:in `require'
    from /opt/local/bin/gem1.9:8:in `<main>'
    
The problem is that Ruby is loading Rubygems from the `site_ruby` folder--older versions of Rubygems associated with MacPorts will go in there, and you don't want them.  Nuke anything related to Rubygems in `/opt/local/lib/ruby1.9/site_ruby/1.9.1` and you'll be good to go.  Your gems are actually located elsewhere, and they'll still be around, so no need to waste an afternoon reinstalling them all.

This probably affects systems other than MacPorts, and if you have the same problem but elsewhere, the solution is probably the same with slightly different paths.
