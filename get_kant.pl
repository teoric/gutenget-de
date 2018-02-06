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
#  Last Change: 2018-02-06, 14:53:03 CET
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
    my $OD = "DATEN";
    GutenbergDE::init_dir($OD);
}

use HTML::TreeBuilder;


# Lese-Liste:
my @reading_list = (
    {
        nr => 3505,
        title => "Was ist Aufklaerung?",
        chapters => 1
    },
    {
        nr => 6344,
        title => "Allgemeine Naturgeschichte und Theorie des Himmels",
        chapters => 6
    },
    {
        nr => 6398,
        title => "Beobachtungen ueber das Gefuehl des Schoenen und Erhabenen",
        chapters => 5
    },
    {
        nr => 3503,
        title => "Gegenden im Raum",
        chapters => 1
    },
    {
        nr => 3510,
        title => "Grundlegung zur Metaphysik der Sitten",
        chapters => 1
    },
    {
        nr => 3506,
        title => "Idee zu einer allgemeinen Geschichte in weltbuergerlicher Absicht",
        chapters => 1
    },
    {
        nr => 3511,
        title => "Prolegomena zu einer jeden kuenftigen Metaphysik",
        chapters => 1
    },
    {
        nr => 3509,
        title => "Der Streit der Facultaeten",
        chapters => 1
    },
    {
        nr => 6452,
        title => "Traeume eines Geistersehers, erlaeutert durch Traeume der Metaphysik",
        chapters => 9
    },
    {
        nr => 6400,
        title => "Nachricht von der Einrichtung seiner Vorlesungen in dem Winterhalbenjahre von 1765-1766",
        chapters => 2
    },
    {
        nr => 6399,
        title => "Untersuchung ueber die Deutlichkeit der Grundsaetze der natuerlichen Theologie und der Moral",
        chapters => 11
    },
    {
        nr => 3512,
        title => "Kritik der praktischen Vernunft",
        chapters => 34
    },
    {
        nr => 3508,
        title => "Kritik der reinen Vernunft (1781)",
        chapters => 132
    },
    {
        nr => 3502,
        title => "Kritik der reinen Vernunft (1787)",
        chapters => 146
    },
    {
        nr => 3507,
        title => "Kritik der Urteilskraft",
        chapters => 106
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
