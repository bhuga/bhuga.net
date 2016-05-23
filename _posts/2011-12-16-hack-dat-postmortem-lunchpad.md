---
layout: post
title: "Hack Dat postmortem for LunchPad"
---
Well, [Hack Dat](http://www.hackdat.org) is over, and we lost. We lost pretty
badly, in fact, because of a decision I made, which I'll get to. But
[LunchPad](http://lunchpadnola.org) lives on, and I learned some things, so
here I am, writing them down. I'm sure that
[@notjoeellis](http://twitter.com/notjoeellis) and
[@mshwery](https://twitter.com/mshwery) learned things, but whatever, they can
write their own blog posts.

First thing learned: I verified my Mongo prejudices. First: Mongo is pretty easy via
the [Heroku](http://heroku.com) addons list. Second: Mongo is good at things
where dynamic schemas are cool. Third: Mongo sucks when you need a relation.
The only thing that surprised me is how good [Mongoid](http://mongoid.org)
actually is, and just how easy Mongo as a Heroku addon. It's easy enough, and
good enough, that the 'moving part complexity penalty' that an application
suffers from adding a new component to the stack is almost nil. I'll be using
it, for what it's good for, in the future.

Second thing: I verifed my [Spira](http://github.com/bhuga/spira) prejudice.
Mongoid is a sterling example of what an ORM based on ActiveModel can be, and
Spira is not, and there's just no reason to do it any other way. Nice job,
Mongoid. This is the primary reason that Spira went moribund, and, well, it was
the right call.

Third thing, and most important thing: I verified my anti-Rails prejudice. I
wrote LunchPad's backend in Sinatra (not open source due to my not trusting the
safety of the code yet), and it only took about 6 hours to have a basic user
authentication system up and running. I only spent about 2 hours on Sprockets
before giving up, but it could be done in not much more time.
[Appetzier](https://github.com/audiosocket/appetizer) handles environments fine.

The takeaway? I would not start another Rails project. There's just no need for
it. I had been suspecting this for a while, ever since I read (very belatedly)
[Steve Yegge's anti-static types blog
post](http://steve-yegge.blogspot.com/2008/02/portrait-of-n00b.html). Yegge's
point in that post is that static types are metadata, and that only n00bs need
metadata. I feel like Rails is the same thing. The fact that a particular line
of code exists in app/controllers/users_controller.rb is metadata. That all of
that code has been replaced with convention does not mean it has no semantic
value, and I would rather my semantic value be code than convention. The code
this convention saves me is not worth it: it's maybe 2 days of work, tops.

That doesn't mean Rails is so terrible. We use it at
[Liveset](http://liveset.com), and it's in use over at [Dydra](http://dydra.com).
Certainly it's not worth removing for it's own sake. I just wouldn't start a
new one; all of that convenience comes with a lot of more-or-less required
upgrade requirements, a treadmill of keeping up with the core. Replacing the
Hard Parts that Rails fixes only takes about 2 days. If you're going to do it
right, why not just do it?

Of course, there's a learning curve, such as losing the wide variety of core
patches that ActiveSupport provides. And of course, we added a line of code, 35
minutes before the close, that checked for something's being `blank?`. Oops. So
LunchPad lost, but it was worth it. Go have fun playing with it, everybody.





