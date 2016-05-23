---
layout: post
title: "Adventures in packet-munging with Telefonica"
---
Good thing that so many ISPs are sullying their names lately, or I might have spent more time on this one.

One of our developers recently moved to Spain to work with some of our contractors for a few months, and he immediately had problems.  He was having problems submitting certain forms on certain pages to a particular machine.  There's got to be a server issue when both phpmyadmin and the application using that database are failing, and for everyone at the office.  They had a connection with [Telefonica](http://telefonica.es), the local Spanish behemoth.

We played with it for a while.  We looked at error logs, we tried other forms on other websites (another developer with our contractor could not log in to [Rubyforge](rubyforge.org)), and we had some other musings, but none of it went anywhere.  I even spent a while messing with bandwidth measurements, since a TCP accelerator problem with one of our satellites in Africa caused very similar issues a few months back.  Eventually, I took a tcpdump at the same time he did and got some strange results.

Developer's results:

    13:24:33.798068 IP x.x.x.x.local.55864 > y.y.y.y.http: . ack 1 win 65535
    13:24:33.798606 IP x.x.x.x.local.55864 > y.y.y.y.http: P 1:678(677) ack 1 win 65535
    13:24:34.323942 IP y.y.y.y.http > x.x.x.x.local.55864: . ack 678 win 65535
    13:24:34.324056 IP x.x.x.x.local.55864 > y.y.y.y.http: . 678:2138(1460) ack 1 win 65535
    13:24:34.493515 IP y.y.y.y.http > x.x.x.x.local.55864: . ack 678 win 6579
    13:24:34.957342 IP y.y.y.y.http > x.x.x.x.local.55864: . ack 678 win 6579
    13:24:35.312801 IP x.x.x.x.local.55864 > y.y.y.y.http: . 678:2138(1460) ack 1 win 65535
    13:24:35.944393 IP y.y.y.y.http > x.x.x.x.local.55864: . ack 678 win 6579
    13:24:37.325466 IP x.x.x.x.local.55864 > y.y.y.y.http: . 678:2138(1460) ack 1 win 65535

My results:

    13:24:34.039365 IP x.x.x.x.21483 > y.y.y.y.www: . ack 1 win 5840
    13:24:34.044362 IP x.x.x.x.21483 > y.y.y.y.www: . 1:732(731) ack 1 win 65535
    13:24:34.044378 IP y.y.y.y.www > x.x.x.x.21483: . ack 732 win 6579
    13:24:34.494733 IP x.x.x.x.21483 > y.y.y.y.www: . 2126:2192(66) ack 1 win 65535
    13:24:34.494745 IP y.y.y.y.www > x.x.x.x.21483: . ack 732 win 6579
    13:24:35.494664 IP x.x.x.x.21483 > y.y.y.y.www: . 2126:2192(66) ack 1 win 65535
    13:24:35.494670 IP y.y.y.y.www > x.x.x.x.21483: . ack 732 win 6579


Huh!  Why are the packet sizes changing by the time it gets to me from him?  This is where I can thank our friendly ISP's for their incompetence in keeping their packet-adjusting programs transparent: I would never have guessed, even 6 months ago, that ISPs would so blatantly screw with their customer's packets just to have a story to tell at the pub later.  Thanks to recent [highly publicized displays of unconscionable behavior by ISP's](http://www.wikileaks.org/wiki/British_Telecom_Phorm_Page_Sense_External_Validation_report), I needn't convince myself that the rest of the world is wrong, and I have a router problem or something.  ISP's really are that bad.

Fortunately, our developers' office was switching from Telefonica to [Jazztel](jazztel.com) the next day, for a bandwidth upgrade.  We could see if that fixed the problem. 

So what happened the next day?

Developer's results:

    11:46:15.199847 IP x.x.x.x.local.63182 > y.y.y.y.http: S 4092983779:4092983779(0) win 65535 <mss 1460,nop,wscale 3,nop,nop,timestamp 47429206 0,sackOK,eol>
    11:46:15.339426 IP y.y.y.y.http > x.x.x.x.local.63182: S 1014263802:1014263802(0) ack 4092983780 win 5792 <mss 1380,sackOK,timestamp 663357440 47429206,nop,wscale 7>
    11:46:15.339497 IP x.x.x.x.local.63182 > y.y.y.y.http: . ack 1 win 65535 <nop,nop,timestamp 47429207 663357440>
    11:46:15.339813 IP x.x.x.x.local.63182 > y.y.y.y.http: P 1:678(677) ack 1 win 65535 <nop,nop,timestamp 47429207 663357440>
    11:46:15.484783 IP y.y.y.y.http > x.x.x.x.local.63182: . ack 678 win 56 <nop,nop,timestamp 663357478 47429207>
    11:46:15.484855 IP x.x.x.x.local.63182 > y.y.y.y.http: . 678:2046(1368) ack 1 win 65535 <nop,nop,timestamp 47429209 663357478>
    11:46:15.639983 IP y.y.y.y.http > x.x.x.x.local.63182: . ack 2046 win 79 <nop,nop,timestamp 663357517 47429209>
    11:46:15.640083 IP x.x.x.x.local.63182 > y.y.y.y.http: . 2046:3414(1368) ack 1 win 65535 <nop,nop,timestamp 47429210 663357517>
    11:46:15.640129 IP x.x.x.x.local.63182 > y.y.y.y.http: . 3414:4782(1368) ack 1 win 65535 <nop,nop,timestamp 47429210 663357517>
    11:46:15.799374 IP y.y.y.y.http > x.x.x.x.local.63182: . ack 3414 win 102 <nop,nop,timestamp 663357555 47429210>
    11:46:15.799473 IP x.x.x.x.local.63182 > y.y.y.y.http: . 4782:6150(1368) ack 1 win 65535 <nop,nop,timestamp 47429212 663357555>
    11:46:15.799511 IP x.x.x.x.local.63182 > y.y.y.y.http: P 6150:6209(59) ack 1 win 65535 <nop,nop,timestamp 47429212 663357555>
    11:46:15.819146 IP y.y.y.y.http > x.x.x.x.local.63182: . ack 4782 win 124 <nop,nop,timestamp 663357560

My results:

    11:46:15.272449 IP z.z.z.z.63182 > y.y.y.y.www: S 1042651241:1042651241(0) win 65535 <mss 1380,nop,wscale 3,nop,nop,timestamp 47429206 0,sackOK,eol>
    11:46:15.272466 IP y.y.y.y.www > z.z.z.z.63182: S 37547187:37547187(0) ack 1042651242 win 5792 <mss 1460,sackOK,timestamp 663357440 47429206,nop,wscale 7>
    11:46:15.408746 IP z.z.z.z.63182 > y.y.y.y.www: . ack 1 win 65535 <nop,nop,timestamp 47429207 663357440>
    11:46:15.421489 IP z.z.z.z.63182 > y.y.y.y.www: P 1:678(677) ack 1 win 65535 <nop,nop,timestamp 47429207 663357440>
    11:46:15.421505 IP y.y.y.y.www > z.z.z.z.63182: . ack 678 win 56 <nop,nop,timestamp 663357478 47429207>
    11:46:15.578903 IP z.z.z.z.63182 > y.y.y.y.www: . 678:2046(1368) ack 1 win 65535 <nop,nop,timestamp 47429209 663357478>
    11:46:15.578914 IP y.y.y.y.www > z.z.z.z.63182: . ack 2046 win 79 <nop,nop,timestamp 663357517 47429209>
    11:46:15.731438 IP z.z.z.z.63182 > y.y.y.y.www: . 2046:3414(1368) ack 1 win 65535 <nop,nop,timestamp 47429210 663357517>
    11:46:15.731444 IP y.y.y.y.www > z.z.z.z.63182: . ack 3414 win 102 <nop,nop,timestamp 663357555 47429210>
    11:46:15.751551 IP z.z.z.z.63182 > y.y.y.y.www: . 3414:4782(1368) ack 1 win 65535 <nop,nop,timestamp 47429210 663357517>
    11:46:15.751557 IP y.y.y.y.www > z.z.z.z.63182: . ack 4782 win 124 <nop,nop,timestamp 663357560 47429210>
    11:46:15.892222 IP z.z.z.z.63182 > y.y.y.y.www: . 4782:6150(1368) ack 1 win 65535 <nop,nop,timestamp 47429212 663357555>

What a shocker--fairly damning proof of another ISP running some sort of ridiculous filtering/inspection/shaping/proxying software.  Except this stuff isn't even good enough to be invisible: it couldn't even put the packets back together properly.  My day is basically spent trying to define <=> across the set of priorities "A", "Top", "1", "A1", "1A", "First", "Primary", and "Pretty Important", and this stuff makes me exceedingly frustrated.  Where can I send an invoice for my time to companies that make me waste 2 hours to discover that we're not even dealing with IP anymore, but some embraced and extended version of it?

I hope that one day it will be profitable enough to run a company that actually provides internet service instead of an ad pipeline.  I know I'd pay more.  In the meantime, nothing to do but grind our teeth until ad replacement by ISP's makes the internet no longer profitable.


