#!/usr/bin/local/perl                                                                                                                                                                                                                 

use Net::Twitter;
use Scalar::Util 'blessed';
use strict;

# initialize variables                                                                                                                                                                                                                      
my ($txt, @sentences, @beginnings, @arr, %db, $print_msg, $max, $src, $stemlength, $stem, @lens);

# SETUP -----------------------------------------------------------------------------
# Full path to the source .txt file
$src = ''; 

# Twitter API settings



# OPTIONS ---------------------------------------------------------------------------
# This sets the final message length to be somewhere between 80 and 130 characters.
$max = 80 + rand(50); 


# Set the length of "tails" or "stems" stored in the DB hash. 
# Setting this to 1 is a standard first-order Markov chain. 
# Setting it to n will produce chains of n-grams
$stemlength = 1;
                                  
# Optionally, uncomment the next two lines to choose the stem length randomly from the @lens list
#@lens = (1,1,1,2,2,4);
#$stemlength = $lens[rand($#lens)];



# LEARN ------------------------------------------------------------------------------
open READ, $src or die "Could not find source file!";;

while (<READ>){
      chomp;
      $_ =~ s/\n|\r|\n\r//ig;
      $txt .= $_;
}
close READ;

@arr = split(/\s+/, $txt);

for (my $i = 0; $i < $#arr; $i++){
    $stem = '';
    unless (defined $db{$arr[$i]}){
        $db{$arr[$i]} = [];
    }
    for (my $l = 1; $l <= $stemlength; $l++){
        $stem .= $arr[$i + $l] . " ";
    }
    push (@{$db{$arr[$i]}}, $stem);
}


map { push(@beginnings, $_) if (/^[A-Z]/) } keys %db;


# CONSTRUCT ---------------------------------------------------------------------------
for (my $t = 0; $t < 10; $t++){
      my $sent = $beginnings[rand($#beginnings)] . " ";
      while (length($sent) < 140){
            my @sofar = split(/\s/, $sent);
            my @from = @{$db{$sofar[$#sofar]}};
            my $next = $from[rand($#from)];
            $sent .= "$next ";
            if ($next =~ /(\.|\?|\!)\s*$/){
                  last;
            }
      }
      push (@sentences, $sent);
}

foreach (@sentences){
    if (length($print_msg) + length($_) < $max){
        $print_msg .= $_;
    }
}

$print_msg =~ s/\s\s/ /g; # trimming out any doubled spaces

# TWEET ----------------------------------------------------------------------------
#twitter config                                                                                                                                                                                                                       
 my $nt = Net::Twitter->new(
      traits   => [qw/API::RESTv1_1/],
     consumer_key => '',
     consumer_secret => '',
     access_token => '',
     access_token_secret => '',

    );

my $result = $nt->update($print_msg);

if ( my $err = $@ ) {
    die $@ unless blessed $err && $err->isa('Net::Twitter::Error');

      warn "HTTP Response Code: ", $err->code, "\n",
           "HTTP Message......: ", $err->message, "\n",
    "Twitter error.....: ", $err->error, "\n";
}



