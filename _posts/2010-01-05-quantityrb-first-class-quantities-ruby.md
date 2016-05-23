---
layout: post
title: "Quantity.rb: first-class quantities for Ruby"
---
I've just put out a [first release](http://gemcutter.org/gems/quantity) of [Quantity.rb](http://github.com/bhuga/quantity), which scratches an itch I had and much more.

Quantity.rb provides first-class Quantity objects, like '12 meters', '1 liter', or '1 dozen'.  More significantly, it supports things like '12 meters * 1 kilogram / 2 seconds**2'.  It was an outgrowth of an attempt to do some automated unit conversions of a project I am working on involving some monitoring, and I wasn't happy with what was out there.  In particular, I wanted to eventually provide the ability to divide one time series of data points by another, regardless of units.  It needed to be something more than 'meters to feet'.  Maybe it didn't need to be this involved, but it's the right way to do it:  anything can be built on top of this.

It's not the first attempt, and perhaps not even the first success.  [Quanty](http://narray.rubyforge.org/quanty/quanty-en.html) is the earliest one I can find, and it does most of what I want.  Unfortunately, it uses yacc, which I have no intention of learning, and the English docs are sparse.  There's something called the [Quantity Management Framework](http://rubyforge.org/projects/quantitymanager/), but I can't find much info about it.

Besides, I figured it would be fun.  I would learn something, and sometimes it's good to have a project with a well-defined scope so that you can Finish It.  Especially when you have a handful of muddy projects mixed with a handful of very long term ones.  So it was the charge of the light brigade.  And I did learn something.  Earlier versions used some class inheritance features that made me learn far more about Ruby's metaobject system than I had ever hoped to.  That was kind of like [this](http://www.youtube.com/watch?v=4RCI8D8avGI) for me.

Anyways, there's more to do, but I'm pleased with the results so far.  Some of the things you can do, from the README:

    require 'quantity/all'
    1.meter                                                 #=> 1 meter
    1.meter.to_feet                                         #=> 3.28083... foot
    c = 299792458.meters / 1.second                         #=> 299792458 meter/second
    
    newton = 1.meter * 1.kilogram / 1.second**2             #=> 1 meter*kilogram/second^2
    newton.to_feet                                          #=> 3.28083989501312 foot*kilogram/second^2
    newton.convert(:feet)                                   #=> 3.28083989501312 foot*kilogram/second^2
    jerk_newton = newton / 1.second                         #=> 1 meter*kilogram/second^3
    jerk_newton * 1.second == newton                        #=> true

    mmcubed = 1.mm.cubed                                    #=> 1 millimeter^3
    mmcubed * 1000 == 1.milliliter                          #=> true

    [1.meter, 1.foot, 1.inch].sort                          #=> [1 inch, 1 foot, 1 meter]

    m_to_f = Quantity::Unit.for(:meter).convert_proc(:feet)
    m_to_f.call(1)                                          #=> 3.28083... (or a Rational)

It's made my [IRB](http://en.wikipedia.org/wiki/Interactive_Ruby_Shell) shell quite the handy calculator.  Try it out for that, if you're CLI-inclined.

This whole affair was also an excuse to release something meaningful via the [unlicense](http://unlicense.org) (I also did a [growl-amqp thingee](http://gemcutter.org/gems/growl-amqp) but it hardly counts).  The unlicense is a framework for releasing code not with a license, but as public domain.  Public domain is something that old timers remember: what used to older copyrighted works.  Originally some pithy few years, copyright these days now lasts for an author's lifetime + 70 years, and it's been several years since anything entered the public domain in the US due to numerous extensions.  Some countries have gone so far down the rabbit hole that one *cannot dedicate things to the public domain*.

This is all the more ridiculous when one considers that most people now believe [copyright is bunk](http://torrentfreak.com/piracy-has-become-mainstream-studies-show-090313/).  Eventually, legal frameworks will respect how the world is, and not how it was.  A lot of people won't release software under the public domain because of the spotty legal status.  A few years ago, people were equally afraid of the GPL until some court cases affirmed the common-sense interpretation of the license.  Let's release some public domain software and push the issue of what happens when you don't have a license at all.  I was hoping to release this on the first of January for [public domain day](http://www.publicdomainday.org/), but it needed more work.  I guess it's not much of a holiday since nothing enters the public domain anymore anyway.

Anyways, 'gem install quantity' and have fun.

