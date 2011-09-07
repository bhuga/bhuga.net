--- 
:drupal_id: 24
:date: 1223388369
:type: story
:title: Matching yum packages on machines
:format_id: 2
:format: Full HTML
:slug: 2008/10/matching-yum-packages-machines
---
Yum, like all of the package managers, is seriously lacking a 'diff' function, i.e. making a machine's list of installed packages match the list of installed packages on another machine.

This is actually a hard problem, so I don't blame the tools for not having a built-in method.  It's rare you want an *exactly* matching package list, anyway.  Much more problematic is that Red Hat has package dependencies I would consider buggy.  Xen, for example, depends on python-virtinst, some python libraries for creating virtual machines via libvirt, Red Hat's vain attempt to keep you from using the same stuff as everybody else.  By adding a layer of python-based abstraction, your system can become less useful and proprietary at the same time, thus meeting several of Red Hat's business needs in one fell swoop!

It sounds like a perfect system, but Xen depends on python-virtinst, which depends on virt-viewer, which depends on gtk2.0.  So installing Xen the Red Hat way means you'll install all of X-windows, and you'll get 4 weekly, very important security vulnerabilities about local privilege escalation attacks based on mouse drivers.  Thus, Doing The Right Thing will probably result in packages you'd rather skip, which is why the generic solution would be very difficult.

I spent a few minutes in #yum on freenet, where a kindly fellow named Geppeto pointed me to the clear building block for any such solution, 'yum shell'.  Yum shell is yum, but you can type transaction commands one at a time and attempt to run it, then modify the set if there was a failure; it's a lot easier than the command line.  It's also happy to accept standard input.  Thus the solution I'm writing up below.

First, a warning:  you need to know what you're doing for this to be a realistic operation.  You might have to override a dependency, and some of the components that might have problems could be utterly worthless or absolutely key to the operation of your system.  If you're not careful, you'll destroy things.  If any of the steps below seemed unintuitive to you, you probably don't want to be doing this.

First we'll need a list of packages on the good machine.  Make sure to get the architecture in the package name if you're using CentOS or Red Hat, both of which have ridiculous dependency strings resulting in most of the OS being installed twice.

<pre>
correct-host$ rpm --queryformat="%{n}.%{arch}\n" -qa | sort | uniq > uniq_good_packages.txt
</pre>

good_packages.txt will look like this:

<pre>
acl.x86_64
acpid.x86_64
alsa-lib.x86_64
amtu.x86_64
anacron.x86_64
apr-util.x86_64
apr.x86_64
.
.
.
</pre>

We'll do the same thing on the target host:

<pre>
[ben@nps1 ~] NPS PRODUCTION $ sudo rpm --queryformat="%{n}.%{arch}\n" -qa | sort | uniq > uniq_existing_packages.txt
</pre>

Now we're into some tricks.  We've got a list of packages and we need to make this a transaction set.  Diff will get us 99% of what we need in terms of creating a transaction set, but there will be a few mistakes.  It's also formatted incorrectly.  The formatting is fixed easily with ruby or perl; here's what I used, saved as yum_diff.rb:

<pre>
#!/usr/bin/env ruby
while line = gets do
  next unless line =~ /^(<|>)/
  line.sub!(/^(<)/,'remove ')
  line.sub!(/^(>)/,'install ')
  puts line
end
puts "run"
</pre>

Give it a go, unless you have your yum configured not to verify before making a transaction.  I keep such warnings on my system, so that I can be as sloppy as this solution is.
<pre>
[ben@nps1 ~] NPS PRODUCTION $ diff uniq_existing_packages.txt uniq_good_packages.txt  | ./yum_diff.rb | sudo yum shell
</pre>

You'll likely have issues.  For example, my source system does not have python-iniparse installed, and I'm not sure if that's an OS version difference or what.  The reason for the discrepancy doesn't matter:  python-iniparse is required for *yum*, which would be pretty tragic to remove.  Conflicts look like this:

<pre>
---> Package python-iniparse.noarch 0:0.2.3-4.el5 set to be erased
--> Processing Dependency: python-iniparse for package: yum
</pre>

Dependency transactions also appear at the end of the transaction to-do list, which will conveniently tell you all of the packages yum's planning to add/remove that you don't want it to. 

Other conflicts may arise.  I don't have 'device-mapper-event' on my source system, and not having it would have led to the removal of my kernel, via the dependency path of kernel requires mkinitrd requires lvm2 requires devivce-mapper-event.  This is the part where you really have to know what you're doing, knowing what all of these packages do is key.  Fortunately, we're doing a unixy solution, so the fix here is easy:

<pre>
[ben@nps1 ~] NPS PRODUCTION $ diff uniq_existing_packages.txt uniq_good_packages.txt  | ./yum_diff.rb | grep -v python-iniparse | grep -v device-mapper-event | sudo yum shell
</pre>

Now for the exciting part.  Red Hat has what I would consider a bug in its dependencies, as mentioned at the beginning of this post.  Xen requires python-virtinst requires virt-viewer requires gtk2.0 requires about the whole install DVD.  Yuck.  You REALLY need to know what you are doing here, as you need to know what python-virtinst does and what virt-viewer does; you can break your system doing this kind of stuff.  Neither matter if you are not using libvirtd, which I do not (in fact, I've been unable to make it work with bridging at all.  Who decides this stuff is the way to go?).  So the solution is:
  
<pre>
[ben@nps1 ~] NPS PRODUCTION $ sudo rpm -e --nodeps python-virtinst
</pre>

The final command?

<pre>
[ben@nps1 ~] NPS PRODUCTION $ diff uniq_existing_packages.txt uniq_good_packages.txt  | ./yum_diff.rb | grep -v python-iniparse | grep -v device-mapper-event | sudo yum shell -y
</pre>

The result?
<pre>
Install     13 Package(s)         
Update       1 Package(s)         
Remove     710 Package(s)
.
.
.
  Erasing   : at-spi-devel                 ##################### [722/724]
 
Removed: GConf2.i386 0:2.14.0-9.el5 GConf2.x86_64 0:2.14.0-9.el5 GConf2-devel.i386 0:2.14.0-9.el5 GConf2-devel.x86_64 0:2.14.0-9.el5 ImageMagick.x86_64 0:6.2.8.0-4.el5_1.1 ImageMagick.i386 0:6.2.8.0-4.el5_1.1 # 700 more packages  
</pre>

This:
<pre>
[ben@nps1 ~] NPS PRODUCTION $ rpm -qa | wc -l
1299
</pre>

Has become:
<pre>
[ben@nps1 ~] NPS PRODUCTION $ rpm -qa | wc -l
577
</pre>

Beautiful!
