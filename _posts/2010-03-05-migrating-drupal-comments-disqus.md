---
layout: post
title: "Migrating Drupal comments to Disqus"
---
### UPDATE:

This has been fixed in a Drupal-ish way.  See <http://drupal.org/node/269010>, and thanks to Rob Loach for taking the time to post in the comments that it's done.  The original post follows, but its mostly a curiosity now.

After learning about Disqus this week, I became quite enamored of it.  Drupal's comment system is swell and all, but I know that I don't have time to set it up as to be as nifty as it could be.  So I think it's swell if someone wants to take it off my hands for free.  The downside is that if I upgrade to D7, I wouldn't get those swell forthcoming RDF-a comments.  But there's a Disqus API, so I can solve that later if it's important to me.

The problem is that having both Disqus and comments enabled makes things confusing.  Each post has a link at the bottom with '13 comments 13 comments and 0 Reactions' or something similar.  Not swell.  I don't want to abandon my existing comments--in particular, my [Puppet vs Chef](http://bhuga.net/2009/09/puppet-vs-chef) and [SPARQL](http://bhuga.net/2009/11/w3c-going-wrong-direction-sparql-11) posts got good feedback from their respective communities.  The Puppet post is #1 on Google for 'puppet vs chef' largely because the authors of both projects commented there.  Hopefully, Disqus would let people track those authors to comments on my site in the future.

So the obvious solution is to just import my comments into Disqus!  I'll just download some module or converter and...and...nuts.  Wordpress and Blogger have the goods, but not Drupal.  So there went another afternoon:  I wrote a [basic importer in Ruby](http://github.com/bhuga/drupal-to-disqus).  Ruby is where the good Disqus library was (even if I did have to [fix a bug](http://github.com/bhuga/disqus/commit/eb1779dd2cc109325a048f694c95bfea98bd131b)).

Drupal comments have features that do not map to cleanly to Disqus, so it has weaknesses.  All the comments are anonymous, and I really miss markdown.  But it worked for me.  Hopefully it helps someone else, too.

