#!/usr/bin/env perl 
#======================================================================
#
#         FILE: get_gut.pl
#
#        USAGE: ./get_gut.pl  [Nr-of-Book] [Nr-of-Book] ...
#        
#          Nr-of-Book can be one of the numbers given in the
#          URL of the text
#
#  DESCRIPTION: Grab Kant Data from Spiegel/Gutenberg
#
#               @reading_list below contains the current Kant
#                             collection on Spiegel/Gutenberg
#
#         BUGS: <NaN>
#       AUTHOR: Teoric <code.teoric@gmail.com>
#      VERSION: 0.2
#      CREATED: 2011-08-23 15:35:01 (CEST)
#  Last Change: 2018-02-06, 14:35:54 CET
#======================================================================

BEGIN {
    push @INC, ".";
}
use strict;
use warnings;
use utf8;  # UTF-8 im Skript erlauben
use feature qw{say state switch unicode_strings};
use autodie;
use IO::Handle;
use open qw{:encoding(UTF-8) :std};
# use charnames qw( :full :short );
# binmode(DATA, ":encoding(UTF-8)");


# Encode brauchen wir doch nicht.
# 
# Allerdings sind (mindestens) im Text "Der Streit der Facultaeten"
# allerlei griechische Buchstaben doppelt escapiert.
#
# use Encode 'find_encoding';
# my $enc = find_encoding("utf8");


use GutenbergDE qw(do_book);
use Path::Class; # Portabel Dateinamen bauen

{
    my $OD = "Karl_May";
    GutenbergDE::init_dir($OD);
}

use HTML::TreeBuilder;


# Lese-Liste:
my @reading_list = (
    { 
        nr => 2329, 
        title => "O1 - Durch die Wüste",
        chapters => 13
    },
    { 
        nr => 2330, 
        title => "O2 - Durchs wilde Kurdistan",
        chapters => 8
    },
    { 
        nr => 2317, 
        title => "O3 - Von Bagdad nach Stambul",
        chapters => 9
    },
    { 
        nr => 2321, 
        title => "O4 - In den Schluchten des Balkan",
        chapters => 9
    },
    { 
        nr => 2322, 
        title => "O5 - Durch das Land der Skipetaren",
        chapters => 8
    },
    { 
        nr => 2333, 
        title => "O6 - Der Schut",
        chapters => 8
    },
);

my %unskip;
my $skip_mode = 0;
if (@ARGV > 0){
    $skip_mode = 1;
    foreach my $nr (@ARGV){
        $unskip{$nr} = 1;
    }
}

foreach my $book (@reading_list){
    next if ($skip_mode && !$unskip{$$book{nr}});
    do_book($book);
}
