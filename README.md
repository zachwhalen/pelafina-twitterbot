markov-twitterbot
=================

A perl-based Twitterbot powered by Markov-chain text-generation. View, use, fork or whatever to your heart's content.

I offer no guarantees that this works well or is written well, but it was an interesting project.

It's originally designed for <a href="http://www.twitter.com/pelafina_lievre">@pelafina_lievre</a>, where the source text
is just the letters in Appendix IIE of *House of Leaves*. It should work for anything else, though.

To use this, you'd need 

1. A source text
2. A Twitter app (with all the keys that come with that)
3. Perl 5 with the Net::Twitter package installed

Once properly set up (that is, Twitter keys all in place and source text correctly accessible), this script can easily run
on a cron job. In my case, I had to call my local user version of perl5 to make sure I got the correct Twitter 
package, and I want it to run every hour at :45 after, so mine looks something like this:

<pre>
45  *	*	*	*	perl -I /home/...<user path>.../perl5/lib/perl5/ /home/...<user path>.../pelafina/msg.pl
</pre>

