#!/usr/bin/local/perl

# This is a perl script that implicates something like a Markov chain model
# to generate text that ends up being tweeted.

# SETUP ------------------------------------------------------------------------
use strict;
use Net::Twitter;
use Scalar::Util 'blessed';

# some variables
my ($txt, @sentences, @beginnings, @arr, %db, $msg, 
$stemlength, $stem, $max, $trunklength, $trunk, $i, $s, $sent, $tail, $toe,
$consumer_secret, $consumer_key, $access_token, $access_token_secret);

# Get these when you create your Twitter application. 
# Make sure it's set to "Read/Write"!
$consumer_secret = '';
$consumer_key = '';
$access_token = '';
$access_token_secret = '';


# sets the maximum length of the message (tweet)
$max = 80 + rand(50);


# Throughout, "stem" refers to length of the output string, 
# "trunk" refers to the length of input string. Set these here.
$trunklength = 1;
$stemlength = 4;

# LEARN ------------------------------------------------------------------------

# Sorry, you'll need your own source.txt
open READ, "whalestoe.txt" or die "Could not find source file!";;
while (<READ>){
      chomp;
      $_ =~ s/\n|\r|\n\r//ig;     
      $txt .= $_;
}
close READ;

# split that txt into a long array
@arr = split(/\s+/, $txt);

# work through that array and build a database
for (my $i = 0; $i < $#arr; $i++){
      $stem = '';
      $trunk = '';

      # look back along the array to build a trunk
      for (my $t = $trunklength - 1; $t >= 0; $t--){
            $trunk .= $arr[$i - $t] . " ";
      }

      # create a hash key value for this trunk, if necessary
      unless (defined $db{$trunk}){
            $db{$trunk} = [];
      }     

      # look ahead to build the "stem"
      for (my $l = 1; $l <= $stemlength; $l++){
            $stem .= $arr[$i + $l] . " ";
      }

      # add the stem to the value paired with the above key
      push (@{$db{$trunk}}, $stem);
}

# CONSTRUCT --------------------------------------------------------------------

# Figure out some plausible sentence-starters
map { push(@beginnings, $_) if (/^[A-Z]/) } keys %db;

# We're going to make 10 sentences, hopefully, to give us options
for (my $s = 0; $s < 10; $s++){
      
      # Pick a random beginning string as input
      my $sent = $beginnings[rand($#beginnings)] . " ";
	
      # No reason for any one sentence to be longer than 140
      while (length($sent) < 140){
            # keep extra spaces from sneaking in
            $sent =~ s/  / /i;
		
            # take the sentence we're building now into an array
            my @sofar = split(/\s/, $sent);
            my $tail = '';

            # grab the last $trunklength values (as $tail) from array to use 
            # as new input
            for (my $t = $trunklength; $t > 0; $t--){
                  $tail .= $sofar[-$t] . " ";
            }

            # from the db, grab the list (@from) of possibly values that 
            # follow "$tail"  
            my @from = @{$db{$tail}};

            # pick one of those toes at random and add it to this sentence
            my $toe = $from[rand($#from)];
            $sent .= "$toe ";
            
            # If our sentence currently ends in punctuation, move on to the next
            if ($toe =~ /(\.|\?|\!)\s*$/){
                  last;
            }      
      }
	
      push (@sentences, $sent);
}   


# Add completed sentences (@sentences) to our output msg until $max length 
# is reached
map { $msg .= $_ if (length($msg) + length($_) < $max)} @sentences;

# Once again, check for unnecessarily doubled spaces
$msg =~ s/\s\s/ /g;

# TWEET ------------------------------------------------------------------------

# Configuration for Net::Twitter
my $nt = Net::Twitter->new(
     traits   => [qw/API::RESTv1_1/],
     consumer_key => $consumer_key,
     consumer_secret => $consumer_secret,
     access_token => $access_token,
     access_token_secret => $access_token_secret,

);

# Send the tweet
my $result = $nt->update($msg);

# Error messages if it didn't work
if ( my $err = $@ ) {
      die $@ unless blessed $err && $err->isa('Net::Twitter::Error');
      warn "HTTP Response Code: ", $err->code, "\n",
           "HTTP Message......: ", $err->message, "\n",
           "Twitter error.....: ", $err->error, "\n";
}
