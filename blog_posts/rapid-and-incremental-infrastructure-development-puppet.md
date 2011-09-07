--- 
:drupal_id: 57
:date: 1267720390
:type: story
:title: Rapid and Incremental Infrastructure Development with Puppet
:format_id: 4
:format: Markdown
:slug: 2010/03/rapid-and-incremental-infrastructure-development-puppet
---
So pretty much everyone has at least heard of [Puppet](http://reductivelabs.com/products/puppet/) by now.  And yes, it's awesome.  But it can be daunting to get started--generally speaking, configuring something with Puppet takes longer than just doing it, and that means that setting something up requires, if not Big Design Up Front, some Big Work Up Front.  You need a puppetmasterd, and some servers, and some config, and it gets a complicated quickly.

What I want is a simple testbed, a dry run setup, where I can run my code repeatedly, just like during normal development.  I want to develop incrementally and flexibly.  Can it be easier?  Of course it can, that's why we have clouds.  I've been working on some infrastructure for a new project, and the workflow I'm using is easy and effective.  I just boot a community EC2 AMI, get git, and pull down my puppet repo.  That repo has a handy script that installs ruby, gem installs puppet (every distro is using a dated version--forget them), and then I'm ready to go.

The directory structure, like most Puppet installations, looks like this:

    - etc
      - puppet
        - setup_puppet.sh
        - modules
          - (the goods)
        - manifests
          - nodes.pp
          - site.pp


From here, it's easy.  `puppet manifests/site.pp` will run the config locally, without a server or any other trouble.  In my development, I have a branch for the actual puppetmaster, which replaces `nodes.pp` from a default node that includes everything into something more meaty.  Everything else is the same.  From here, I can hack away, testing as I go.  Add a `--noop` to do dry runs.  Add `-d` to enable debug mode and see exactly what commands are run.

The setup script is dirt simple:

    #!/usr/bin/env bash
 
    # libopenssl-ruby1.8 isn't necessarily required with this, 
    # but you do need it for the puppetmaster server.
    sudo apt-get install -y rubygems libopenssl-ruby1.8
     
    sudo gem sources --remove http://gems.rubyforge.org/
    sudo gem sources --add http://rubygems.org 
    sudo gem install puppet --no-rdoc --no-ri

    # Debian weird path
    export PATH=$PATH:/var/lib/gems/1.8/bin

4 hours of very productive infrastructure work cost me about 35 cents.  No puppetmasterd, no existing servers, and no temptation to store meaningful config on the local disk (since I shut these instances down after a few hours, as I'm [easily distracted](http://r33b.net/)).  No messing around.  I really like this workflow.

As an aside, this workflow is fast enough that two Ubuntu gotchas are now actually a problem for me.  Firstly, the [official AMIs from Cannonical](http://alestic.com/) now require the initial login to be via the 'ubuntu' user, which is a pain, because now root can't effectively git clone anything without more hoops.  Secondly, Rubygems is broken on Debian.  It flatly refuses to run `gem update --system`, and when you force it to with the rubygems-update gem, it manages to lose track of all installed gems, including Puppet.  Since any Puppet gathers all information before doing anything, it will read that Puppet is installed, and any code that runs the gem update won't understand that Puppet now needs to be reinstalled.  I'm not sure this can be worked around in Puppet at all; it might have to be out of band.

This is a well-known issue, it's more than 2 years old, and I can't find why this is the way it is.  Google results are too full of people working around the problem to find an actual discussion of the original issue.  Rubygems.org [has a faq](http://help.rubygems.org/faqs/rubygems/rubygems-upgrade-issues) on the issue, but I did find a [the Debian issue](http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=452547) in which this appears to have been done instead of simply fixing the problem.  I'm not sure if this has to do with a wonky directory setup, or if Debian just assumes I'd put an eye out with that much Power.  Either way, tons of people have problems with it, and it seems curious to me that Debian has decided they should suffer.  And it *is* a decision: Rubygems has been updated a number of times since 2007, and the disabling code had to be explicitly upgraded at least once that I found.

Anyways, the next bit of agile infrastructure work I do will be on a [RightScale Centos 5.4 AMI](http://developer.amazonwebservices.com/connect/entry.jspa?externalID=3300&categoryID=223).  What's the point of being agile if you don't try new things?

_Updated:_ Centos 5.4 is running Ruby 1.8.5.  I guess being agile is about trying hopelessly outdated things, too.
