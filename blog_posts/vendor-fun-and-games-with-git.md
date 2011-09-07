--- 
:drupal_id: 27
:date: 1224970127
:type: story
:title: Vendor fun and games with git
:format_id: 2
:format: Full HTML
:slug: 2008/10/vendor-fun-and-games-with-git
---
I spent some time today setting up the SCM and issue tracking for the <a href="www.seasteading.org">seasteading website,</a> having recently fooled them into thinking I'm qualified to administrate their site.  This was the first time I put an existing project into git.

I was pretty disappointed with how it went.  When I finally learned SCM, it was on subversion (I can't use CVS, and don't intend to learn).  I've shoved a system down my developers' throats in which vendor code is saved off in vendor land, just like all vendor code is done in all subversion repos, and that works fine.  I've also recently been using some git for some ruby stuff on the side, and I'm way impressed.  The Github model, with public pushing and pulling, makes it so ridiculously easy to contribute back to a project it's almost easier to give a patch back than not to.  I'm going to start ordering Github Kool-Aid by the case.

But today, the first thing I wanted to do was update the Drupal core, so it's time for vendor code.  In subversion, I'd put both versions of Drupal (current and previous) and copy the changeset of the upgrade into my working copy:

<pre>
$ cd vendor/drupal/core
$ svn copy 6.2 6.3
$ cd 6.3
$ <wget new version, unpack, overwrite files>
$ svn ci -m "Update drupal core to 6.3"
Committed revision 5
$ cd ../../../trunk/drupal/core
$ svn merge -c 5 .
</pre> 

This copies the same set of changes from the vendor upgrade to the trunk upgrade.  I can even generate changesets between whatever version I want:
<pre>
$ cd trunk/drupal/core
$ svn merge http://svn/vendor/drupal/core/6.0 http://svn/vendor/drupal/6.4 .
</pre>

Backwards merges (merge a changeset back):
<pre>
$ cd trunk/drupal/core
$ svn merge -c -5 .
</pre>

You get the idea.  I can merge any changeset, or the difference between two versions of any two files at any revision, and apply it to any set of files that can accept that changeset; the original ancestry is irrelevant.

Git's not letting me do this.  The folks on IRC are helpful, and I can do what I need, but I feel it's a lot more awkward.  There's no way to create a changeset from the difference between two files at different places in the repo, and there's no way to apply a change to anything but the file in which said change was originally made.

In the git model, you would start from scratch, with core drupal, and commit it.  Then you'd code away.  When it comes time to update drupal, you branch and apply.  If you've edited core, you branch from your very first commit--from naked drupal--and commit there.  Then you merge back to your master and merge that changeset back.  

It works pretty well, but what if I have a project that's already halfway done?  I can do it backwards, by starting from Drupal, then exploding the new project on top of it, but that feels awkward to me.  What I ended up doing was creating a branch, installing the base version of the version of Drupal I wanted to upgrade, committed, exploded the most recent version of Drupal, and committed.  Then I can switch back to master and apply the difference between the two commits:
<pre>
$ git checkout master
$ git branch drupal-core
$ git checkout drupal-core
$ <unpack old version of drupal>
$ git commit -a
$ <unpack new version of drupal core>
$ git commit -a
$ git checkout master
$ git diff 89dca98 0f1ac4s | git-apply
</pre>

This is uncomfortable to me; perhaps I'll get used to it.  I don't really think it's any more or fewer steps than putting things in vendor, but when integrating several pieces of vendor code, I think this would get confusing.  I don't like how vendor code has to exist in the exact same directory on the trunk branch as the branch where it's unedited.  Especially considering that there is an excellent copy of <a href="http://github.com/mikl/drupal/tree/master">Drupal on Github,</a> it drives me nuts that there's no way to do this.  Why can't I tell Github 'Give me the difference between Drupal 6.1 and Drupal 6.4'?  Even if I download this repo, there's no way to do it; it's a different repository and I cannot find a way to copy the information into mine (I would not want to, anyway: the Drupal repo is some 22 megs).

All of that being said, I still prefer git.  Now that I've climbed this little hurdle, it's completely appropriate for the project and hopefully we can make it public (waiting to hear back from the original devs about licensing) and get some fixes and all.  But I'm now skeptical of git for a project that is mainly one of integration, which is my day job.

To be fair, this doesn't have to be a problem.  This is as much a problem with PHP and/or Drupal as it is with git.  Rails neatly solves the problem by having vendor code in /vendor right there in the live copy of the software, rather than only in the fantasy world of SCM. Code you write is here.  Code you download is over there; it's like apartheid software development.  Need to edit it?  Re-open the classes and monkey patch it.  Compare this with PHP, in which you re-open classes after typing ?> and tossing in some css style definitions in the middle of a constructor.

Git provides very nice little submodules; they work quite well if vendor code is completely separate from user code as in rails.  They're useless for the usual PHP model of throwing everything in the main directory.  Things like config.inc.php.  Seriously, there are still projects with this model, Drupal included.  Why?  Why do Drupal sites live, from index.php, in ./sites/sitename?  Why is there any sharing of directory space at all?  I'm continually amazed that something as genuinely useful as Drupal comes from such miserable beginnings. 

I hope I'm missing something obvious, and I'll bet that 10 seconds after I post this, someone is going to tell me how to do what I want.  But oh well--such embarrassment is occasionally the price of knowledge.
