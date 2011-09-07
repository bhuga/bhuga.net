--- 
:drupal_id: 54
:date: 1263404141
:type: story
:title: The Promising Future of the Unlicense
:format_id: 4
:format: Markdown
:slug: 2010/01/promising-future-unlicense
---
So the public launch of the [unlicense](http://unlicense.org) movement on January 1st has gone better than expected.  [Arto's post](http://ar.to/2010/01/set-your-code-free) hit top of the list for 'most controversial' on Reddit for a while, and [unlicense.org](http://unlicense.org) itself is seeing decent traffic.  Since the target audience of the site is developers, even a few thousand eyeballs is a good number, and that number is being handily beaten.

There are three main concerns that seem to keep appearing in [discussions](http://ostatic.com/blog/the-unlicense-a-license-for-no-license) in regards to releasing software into the public domain.  I'd like to briefly offer a response to them, and then provide an example of why [public domain](http://me.stpeter.im/essays/publicdomain.html) might be what you're looking for for your software.

### Concern 1: Only the GPL preserves *F*reedom!

This is amazing to me.  There is an incredible amount of worry, it seems, that faceless corporate Cthulhu-associated entities are lurking in the shadows, just waiting to pounce on vulnerable code unprotected by the GPL's armor.  These faceless horrors have crushed promising startup projects with vulnerable licenses like [Apache](http://httpd.apache.org/) (the world's most-installed web server), [SQLite](http://sqlite.org) (the world's most-installed SQL server) (and public domain, not actually licensed at all, by the way), [BIND](http://www.isc.org/software/bind) (the world's most-installed DNS server), and other sad stories.  I find this concern so unrealistic it boggles the mind.

But just for fun, let's start a *real* flame war.  Numerous folks out there claim, with a certain sort of correctness, that the GPL keeps software free from the lockdown of derivative works.  This is called Freedom (capital F).  However, that software's Freedom is enforced by a copyright, which restricts the actions of people by proscribing certain kinds of copy and use.  These proscriptions are enforced via a system with far reaching effects, which prevent me, for example, from purchasing a DVD player that disregards region codes.

The inevitable conclusion is that the GPL is about valuing the 'Freedom' of bits over the freedom of humans.

You, dear reader, are far more important than my code, regardless of your choice of license.  I have no time for a moral system that makes such claims on your [autonomy](http://www.jonathangullible.com/philosophy-of-liberty).  I will avoid that system as much as possible:  by using [the unlicense](http://unlicense.org/UNLICENSE).

### Concern 2: [Statutory Law](http://en.wikipedia.org/wiki/Statute_law) vs [Common Law](http://en.wikipedia.org/wiki/Common_law)

Statutory law, such as that of many European states, often fails to specify a process for explicit public domain donations, leading many to wonder if such a thing is even possible.  Folks better educated than I seem to have differing opinions.  But I'll note that if you're concerned about it, there is precedent.  The original w3 server, which was owned by CERN (guess what the 'E' stands for?), was [placed into the public domain in 1993.](http://tenyears-www.web.cern.ch/tenyears-www/Welcome.html)

Apache and Netscape both trace their heritage back to European public-domain software.  You'd be foolish to accept this post as legal advice, of course, but in my mind, those are perfectly acceptable European counter-examples.

### Concern 3: Moral rights cannot be relinquished

A true concern, many jurisdictions specifically prohibit the relinquishment of 'moral rights' of authorship, namely, the right to be the named author of a work, and the right to not have works you did not author attributed to you.  To my mind, this a not a problem of copyright, it's basically statutory encoding of the fact of authorship.  The issue is muddied by several states conflating copyright enforcement with moral rights enforcement.  While again not legal advice, I'd say that simple attribution covers you.

Concerns 2 and 3 really bother me, because legal arguments against them are complicated and require specialized knowledge.  I'm not qualified to argue them in a bulletproof manner.  But most software will never become big enough to have a license (or unlicense) issue, and you can issue someone an explicit license if it's ever a problem ([as SQLite does](http://www.sqlite.org/copyright.html)).

### How public domain lets your software grow

>"CERN's decision to make the Web foundations and protocols available on a royalty free basis, and without additional impediments, was crucial to the Web's existence. Without this commitment, the enormous individual and corporate investment in Web technology simply would never have happened, and we wouldn't have the Web today."

>*Tim Berners-Lee, Director, WWW Consortium*

The public domain is the best way that others can take your ideas and run with them.  CERN's public-domain dedication is probably the best example of that, but if you want your software to change the world, you need to allow others to use it as freely as possible.  I'll give you a little personal example.

A few days ago, I published [promising future](http://github.com/bhuga/promising-future), a [Ruby gem](http://gemcutter.org/gems/promise) that adds Scheme-style promises and futures to Ruby.  I did this because I happen to love [promises and futures](http://en.wikipedia.org/wiki/Futures_and_promises), and it drives me absolutely nuts whenever they are not available.

If my goal is (and it is) to always have promises and futures available, the ideal would be that it were in the Ruby core library, or even a language future.  I could start a rallying cry on a mailing list somewhere, and may yet, but my odds are slim.  But what if a much better known author, with a much more popular library, wants to use these lovely little things in his code?  Well, they could add a gem dependency, but that's not a popular option for various reasons.  If the licenses work out, they could incorporate the code, usually requiring a note of attribution.

But my promises and futures code has the maximum possible flexibility.  *Anyone*, with or without any license, can copy/paste my promises and futures into their code, without attribution, and be done with it.  Problem solved.  My code lives on, or at least inspires the creation of equivalent functionality implemented in a better way.  And maybe, one day in a promising future, every Rubyist everywhere will have promises and futures available.  That [SQLite can be embedded](http://www.sqlite.org/famous.html) in other software is a huge factor in its unparalleled adoption.

How could my software be more free?  How could I be more free?  How could you be more free?  What could be better?  Public domain promises a very [promising future](http://questioncopyright.org/promise) indeed.
