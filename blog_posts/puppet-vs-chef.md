--- 
:drupal_id: 46
:date: 1253380675
:type: story
:title: Puppet vs Chef
:format_id: 2
:format: Full HTML
:slug: 2009/09/puppet-vs-chef
---
I spent a fair bit of time this week messing with <a href="http://wiki.opscode.com/display/chef/Home">Chef</a>, which I had somehow missed in my previous rounds of scooping up system administration tools.  It was kind of a late-in-the-game evaluation--I was already in the process of deploying <a href="http://reductivelabs.com/products/puppet">Puppet</a> when it was brought to my attention.  But it was only almost too late, not too late, so I threw up some VMs and did some testing.

I was not really enthralled by Chef.  Not, at least, for the particular use case I was solving.

It seems pretty awesome.  In <a href="http://www.engineyard.com/blog/2009/chef/">this post</a> over at Engine Yard, the problem with puppet is summed up rather nicely: <i>Puppet’s biggest flaw is its configuration language that is not quite ruby and not quite turing complete. So you end up wrestling with it to get it to do anything.</i>  This is completely true--much like you end up doing cuts for the simplest of things in Prolog, Puppet's DSL is declarative and starts as hassle and never really stops.  It seems like a better idea than it is.  There are a lot of cases where people need to run puppet twice to get dependencies to work out right.

Inadvertently, however, the sentence before that quote is the big problem with chef:  <i>The big advantage Chef has over Puppet is that the codebase is 1/10th the size and it is pure ruby, including the recipe DSL.</i>  I am, unfortunately, not measuring the quality of my configuration management system based on how many lines of code it is.  Nor am I measuring it's 'ruby purity'.  These are, however, Chef design goals.  This zealous hunting of unquantifiable elegance feels, to me, to be endemic in the ruby world.  It's a fine goal, but it also tends to encourage one to re-invent components that did not need reinventing.  It's usually foolish to think that if you start a project over that it will be any better than what you're replacing.  I don't think that Chef is really any better than puppet for most situations, syntactic elegance notwithstanding.  There are important exceptions, though, so keep reading.

My first experience with Chef was an uneasy installation process.  There's no description of how to install Chef.  Instead, there are Chef scripts that install Chef for you.  That might not be so bad, but if there are <a href="http://github.com/bhuga/cookbooks/commit/2c53d27a40fc59eae5f08762768355988d684f9d">stupid problems</a>, it can be difficult to follow.  

After a while, I figured out that Chef is just another Merb application with a CouchDB backend.  It's a Merb application which requires you to have an OpenID to log in to it, and which requires 2 web servers so that you can have an OpenID server separate from the Chef server (I think).  But okay, it's Merb.  I've played with it before.

But honestly, that is about as far as I got in terms of making it do things.  I never made the server push a useful config to a client.  I would not even have gotten to the web interface without <a href="http://codesorcery.net/meerkat">Meerkat</a>, because it uses Apache's SSL instead of letting me have the option of using an SSL concentrator.  By comparison, puppetmaster's client-server model, which probably uses a lot of those precious, precious lines of code, works pretty much flawlessly from any number of RPM sources, or from gems.  

I spent a while going over recipes, and comparing them to Puppet.  For example, here's some code to manage sudo for Chef.  The Chef code was written by Chef's authors; the Puppet code was written by myself.  The Chef code is spread across 3 files.  

<pre>
# recipes/default.rb:
package "sudo" do
  action :upgrade
end
 
template "/etc/sudoers" do
  source "sudoers.erb"
  mode 0440
  owner "root"
  group "root"
  variables(
    :sudoers_groups => node[:authorization][:sudo][:groups], 
    :sudoers_users => node[:authorization][:sudo][:users]
  )
end
# attributes.rb:
authorization Mash.new unless attribute?("authorization")
 
authorization[:sudo] = Mash.new unless authorization.has_key?(:sudo)
 
unless authorization[:sudo].has_key?(:groups)
  authorization[:sudo][:groups] = Array.new 
end
 
unless authorization[:sudo].has_key?(:users)
  authorization[:sudo][:users] = Array.new
end
# metadata.rb:
maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Installs and configures sudo"
version           "0.7"
 
attribute "authorization",
  :display_name => "Authorization",
  :description => "Hash of Authorization attributes",
  :type => "hash"
 
attribute "authorization/sudoers",
  :display_name => "Authorization Sudoers",
  :description => "Hash of Authorization/Sudoers attributes",
  :type => "hash"
 
attribute "authorization/sudoers/users",
  :display_name => "Sudo Users",
  :description => "Users who are allowed sudo ALL",
  :type => "array",
  :default => ""
 
attribute "authorization/sudoers/groups",
  :display_name => "Sudo Groups",
  :description => "Groups who are allowed sudo ALL",
  :type => "array",
  :default => ""
</pre>

Here's more or less the same thing for Puppet:

<pre>
class sudo {

  package { ["sudo","audit-libs"]: ensure => latest }

  file { "/etc/sudoers":
    owner   => root,
    group   => root,
    mode    => 440,
    content => template("sudo/files/sudoers.erb"),
    require => Package["sudo"],
  }
}
</pre>

Both Chef and Puppet then take this information and output it through an ERB template, which is an exercise for the reader, since it's basically the same for both.

There's a few things worth noting here.  First of all, Puppet has zero metadata available.  If you want to set sudo-able groups, you need to know those variable names ahead of time and set them to what you want.  Both your template and whatever code sets your sudo-able groups must magically 'just know' this information.  Since the Puppet DSL is not even Ruby, you have *zero* ability to perform any kind of metadata analysis on these attributes in order to make code more generic.

Chef gives you complete metadata about the variables it's using.  This is powerful and indeed critical in my imagined use domains for Chef (keep reading).  That metadata comes at a cost of a lot of boilerplate code, though.  Chef comes with some rake tasks to generate some scaffolding.  I'm always uncomfortable with scaffolding like this; I think this kind of code generation is a bad way to do metaprogramming.
 
Chef spreads this information across 3 files, named a particular way.  Puppet has a similar scheme of magically named files, but it's basically just a folder structure, a file called init.pp, and templates/source files.  For a fairly simple task, Chef requires you to know a folder structure and 3 file names, and which data goes in which files.  This is congruent with the Ruby world's (perhaps specifically the rails/merb world's?) general practice of 'convention not configuration'.  This is in addition to all of the 'you just have to know' parts of the Chef system which are taken from Merb, such as where models and controllers live, though you would not need to edit those save for pretty advanced cases.

Lastly, Chef provides you with an actual data structure that is fed to the sudoers template.  Puppet simply uses available dynamically-scoped variables in its template files.  This is *awful*, and a big loss for puppet.  I administrate Zimbra servers, for example, which require extra content in sudoers.  I cannot add this to the zimbra module unless the zimbra module were to be the one including the sudo module.  There are solutions to this, of course, but this is a really, really simple use case and we're already <a href="http://projects.csail.mit.edu/gsb/old-archive/gsb-archive/gsb2000-02-11.html">shaving yaks.</a>  Chef's method is undeniably superior.

All 3 of these are part of the same core difference between the two:  Puppet is an application, and Chef is a part of one.

Chef is a library to be used in a combined system of resource management in which the application itself is aware of the hardware it's using.  This allows certain kinds of applications to exist on certain kinds of platforms (particularly EC2) that simply couldn't before--an application using this system can declare a database just as well as it can declare an integer.  That's fundamentally powerful, awesome, amazing.

Puppet is an application which has an enormous built-in library of control methods for systems.  The puppet package manager, for example, supports multiple kinds of *nix, Solaris, HPUX, and so forth.  Chef cookbooks can certainly be written to do this, but I imagine by the time you supported everything puppet does I don't think Chef would get a smiley-face sticker for being tiny and pure with extra ruby sauce.  Puppet's not a fundamental change, it's just a really nice workhorse.

I picked puppet for the project I'm working on now.  It made sense for a lot of reasons.  Probably first and foremost, there are 3 other sysadmins working with me, some split between this project and others.  None of us are ruby programmers.  We don't write rake tasks like we configure Apache, we don't want to explain to new hires the difference between a symbol or a variable, or where the default Merb configuration files, or 100 other ruby-isms.  Meanwhile, most puppet config, silly folder structure aside, is not any harder to configure than something like Nagios.  I think it would be a mistake for an IT shop with a lot of existing systems running various old-fashioned stateful applications like databases or LDAP to suddenly declare that sysadmins need to be Merb programmers.

Puppet's much deeper out-of-the-box support for a lot of systems provides the kind of right-now real improvements that a lot of IT shops and random contractors desperately need.  System administration is depressingly rarely about being elegant or 'the best' and much more frequently about being repeatable and reliable.  It's just the nature of the business--if the systems ran themselves, there would be no administrators.  Having a bunch of non-programmers become not just programmers but programmers specializing in a tiny subset of the ruby world is a lot of yaks to shave for an organization.  This is not some abstract jab at my colleagues:  I am most certainly not a Merb programmer, and even if I were, I have too many database copies to make, SQL queries to run, mysterious performance problems to diagnose and deployments to make to give this kind of development the attention it requires.  How many system administrators do you know that use the kind of TDD that Merb can provide for their bash scripts?  What would make one think that's going to happen with Chef?

The other big reason I picked Puppet is that it's got a sizable mailing list, a friendly and frequently used google group for help, and remains in active development after a couple of years.  I don't think Reductive Labs is going away, and if it did, there have been a lot of contributors to the code base over those 2 years.

It's worth noting, though, that the Chef guys come with an impressive set of resumes.  It seems to be somehow tied in with Engine Yard (several presentations about Chef include Ezra Zygmuntowicz as a speaker).  I worry, though, that they are working the typical valley business model, namely to explode about a year after launch.  Chef was released about 8 months before I write this.  The organization I am installing Puppet for does not have the Ruby talent base required to ensure that they can fix bugs as required in the long term if Opscode goes away, or if they get hired on to Engine Yard and they make Chef into the kind of competitive differentiation secret it could be.

Chef currently manages the EC2 version of Engine Yard, and that's just the kind of thing I cannot imagine using puppet for:  interact with a giant ruby application to manage itself.  If you have a lot of systems joining and leaving the resource pool as required, Chef's ability to add nodes dynamically is going to save you.  The ability to define resources programmatically is very powerful--one could easily imagine reducing the number of web server threads if a system's CPU use goes over a certain threshold, for example.  I would not try that in puppet!  But note that this is an application built from scratch to expect such a command and control system to exist.  If you're just managing a bunch of LAMP stacks and samba servers, this is more power than you need.  One of the Opscode founders has <a href="http://www.slideshare.net/jesserobbins/using-chef-for-automated-infrastructure-in-the-cloud">some slides</a> that talk about this kind of model.

And Chef is powerful for that model, sure, but is that even the model you want for your applications?  Applications should not have to worry about the hardware they use.  Making an application's own hardware use visible to itself encourages programmers to spend time thinking about issues they should be trying their hardest to ignore.  A better model is App Engine's, where the system just scales forever without developer intervention.  Even <a href="http://msdn.microsoft.com/en-us/library/dd179389.aspx">Azure's service configuration schema model</a> is better, in which different application roles (web, proxy, etc) are described as resources and given a dynamic instance count, and transparently scalable data stores are available.  The number of 'nodes' in the system is never an issue for either model.

Chef is what you'd use to build that auto-scaling backend.  Engine Yard uses it for, well, Engine Yard--scalable rails hosting, transparently sold as a service to folks who can then just blissfully program in rails and never think about Chef.  Very few organizations are making that infrastructure, and most of them that are are shaving really big yaks and need to stop and use one of the available clouds.

Meanwhile, a very many organizations are running 6 kinds of *nix to maintain tens of older applications built on the POSIX or LAMP paradigms, or hosting virtual machines running applications made who knows when.  For these organizations, Puppet is probably the easiest thing that could work, and thus probably the best option.

I'm sure there are sysadmins out there who think I'm completely wrong, and that you just can't beat the elegance Chef provides.  There are a lot of people better than me out there, and I'm sure they have a point.  But in my experience, bad system administration happens when sysadmins try and do everything for themselves.  For a given situation in system administration, it's highly unlikely a sysadmin can do a better job than an available tool.  Puppet's sizable default library is what most organizations need, not the ability to write their own.

And all of the above aside, one thing is clear:  there is little excuse for an organization with 3 or more *nix servers not to be using Puppet, Chef, cfengine, or *something*.  I would argue that about 80% of the virtualization push is dodging some of the core questions of system administration, making systems movable to new resources indefinitely rather than making their configuration repeatable, but that's a topic for another post.  Especially since nobody got this far on this one anyway.
