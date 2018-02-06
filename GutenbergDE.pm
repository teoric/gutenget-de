#!/usr/bin/env perl
#======================================================================
#
#  PACKAGE GutenbergDE
#
#  DESCRIPTION: Grab Data from Spiegel/Gutenberg
#
#     PROCEDURES:
#         init_dir($output_dir): set output directory
#         do_book(\%book_info): grab book
#           with:
#             %book_info = (
#                 nr => <Number of Book in Spiegel/Gutenberg>,
#                 chapters => <Number of Chapters>,
#                 title  =>  <Title of the Book>
#                            (used for subdir of $output_dir)
#             )
#
#         BUGS: <NaN>
#       AUTHOR: Teoric <code.teoric@gmail.com>
#      VERSION: 0.2.1
#      CREATED: 2011-08-23 15:35:01 (CEST)
#  Last Change: 2018-02-06, 14:55:58 CET
#======================================================================

package GutenbergDE;

require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(do_book init_dir);

use strict;

use warnings;
use utf8;  # UTF-8 im Skript erlauben
use feature qw{say state switch unicode_strings};
use if $^V ge v5.14.0,
    re => "/u"; # unicode regex possible after Perl 5.14
use autodie;
use IO::Handle;
use open qw{:encoding(UTF-8) :std};
# use charnames qw( :full :short );
binmode(DATA, ":encoding(UTF-8)");


# Encode brauchen wir doch nicht.
#
# Allerdings sind (mindestens) im Text "Der Streit der Facultaeten"
# allerlei griechische Buchstaben doppelt escapiert.
#
# use Encode 'find_encoding';
# my $enc = find_encoding("utf8");


use Path::Class; # Portabel Dateinamen bauen

use List::Util qw(sum);

my $OVZ;

use HTML::TreeBuilder;

my $HEADER;
{
    local $/ = undef;
    $HEADER //= <DATA>;
}

sub sanitize_filename{
    # resultierender Dateiname ist auch für Windows geeignet.
    # Enthält keine ASCIIfizierung!
    my $ret = shift;
    my $replacement = shift() // "_";
    $ret =~ s{\s+}{$replacement}gu;
    $ret =~ s{[\\'/|:<>"?*]|\n}{$replacement}gu;
    # mindestens <>| sind keine \p{Punct}

    # nicht zu viele __ und nicht am Schluss:
    $ret =~ s/(?:$replacement){2,}//g;
    $ret =~ s/(?:$replacement)+(?=\.|\Z)//g;
    return $ret;
}


sub url_to_filename{
    # sollte man sich vielleicht noch einfacher machen
    my $fn = shift;
    my $digits = shift;
    my $extn = shift;
    $extn = ".".$extn if ($extn !~ /^\./);
    my $replacement = shift() // "_";
    $fn =~ s/(\d+)$/sprintf "%0${digits}d", $1/e;
    $fn =~ s{^(?:\w+:/*)}{}u;  # Erfasst z.B. nicht <>|
    $fn =~ s{[/\p{Punct}]}{$replacement}g;
    return sanitize_filename($fn, $replacement)."$extn";
}

use  HTTP::Tiny; # ab 5.14 im Core; sonst # < 5.14
# require LWP::UserAgent;
use  HTML::Entities;

my $ua = HTTP::Tiny->new();
# my $ua = LWP::UserAgent->new; # < 5.14
# $ua->timeout(10);
# $ua->env_proxy;

use Text::Wrap qw(wrap $columns);
# use Text::WrapI18N qw(wrap $columns); # wäre noch besser, ist aber lahm
$columns = 72;

sub umbruch{
    my $ret = shift();
    $ret =~ s{<(?:p|blockquote|ul|ol|li|h[1-9])\b}{\n\n$&}g;
    return wrap('','',$ret);
}

sub make_header{
    my ($title, $nr, $head) = @_;
    $head =~ s/\(TITLE\)/$title $nr/g;
    return $head;
}
sub get_guten_text{
    my $url = shift();
    my $serialize = shift() ? "as_XML" : "as_HTML";
    my $title = shift();
    my $nr = shift();

    my $tree;
    my $ret; # Rückgabewert
    my $u = $ua->get($url);
    if ($u->{success}) {
    # if ($u->is_success) { # < 5.14
        # $tree = HTML::TreeBuilder->new_from_content($u->decoded_content); # < 5.14
        $tree = HTML::TreeBuilder->new_from_content($u->{content});
    }
    else {
        die "Huch, habe «$url» nicht lesen können!"
    }
    my $mother = HTML::TreeBuilder->new_from_content(
        make_header($title, $nr, $HEADER));
    my $body = $mother->find("body");
    # Naja, eigentlich sollte es nur eine DIV mit der ID geben, aber…
    for my $div ($tree->look_down(
            _tag => 'div',
            id => qr/^gutenb$/,
        )) {
        for my $fn ($div->look_down(
                _tag => 'span',
                class => qr/\bfootnote\b/,
            )) {
            $fn->tag("fussnote");
            $fn->attr("class",undef);
        }
       $body->push_content($div);
    }
    $tree->delete();
    # doppelt decode_entities, weil Gutenberg Bugs hat
    return decode_entities(decode_entities($mother->$serialize()));
}

sub init_dir{
    my $GUTEN_DIR = shift();
    $OVZ = dir($GUTEN_DIR);
    $OVZ->mkpath(); # Verzeichnis ggf. anlegen
}


sub do_book{
    # Buch abarbeiten und Daten rausschreiben nach
    #   $OVZ/Titel/&{url_to_filename}
    # (Achtung: In Dateinamen können Nicht-ASCII-Zeichen vorkommen,
    # s.o.)
    my $info = shift;
    my @urls; # Stapel von URLS für ein Buch
    my $chaps = $$info{chapters};
    my $nr = $$info{nr};
    use POSIX qw/floor log10/;
    my $digits = 1 + floor(log10($chaps));
    for my $i (1..$chaps){
        push @urls, "http://gutenberg.spiegel.de/buch/${nr}/${i}" ;
    }

    my $BVZ = $OVZ->subdir(sanitize_filename($$info{title}));
    # say STDERR $BVZ;
    $BVZ->mkpath(); # Verzeichnis ggf. anlegen
    my $i;
    foreach my $url (@urls){
        $i++;
        printf STDERR "%-45s %s\n", $url, $$info{title} ;
        open my $of, ">:encoding(UTF-8)",
            $BVZ->file(url_to_filename($url, $digits, $info->{xml} ?
                    ".xml" : ".html"));
        say $of umbruch(get_guten_text($url, $info->{xml}, $info->{title}, $i));
        close($of);
    }

}


1;
__DATA__
<html>
    <head>
        <title>(TITLE)</title>
        <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    </head>
    <body></body>
</html>
