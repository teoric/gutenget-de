#!/usr/bin/env perl 
#======================================================================
#
#         FILE: get_gut.pl
#
#        USAGE: ./get_gut.pl  [Nr-of-Book] [Nr-of-Book] ...
#        
#          Nr-of-Book can be one of the numbers given in the
#          @reading_list below; the program will then only grab the
#          books assigned.
#
#  DESCRIPTION: Grab Data from Spiegel/Gutenberg
#                (modular version depending on GutenbergDE)
#
#         BUGS: <NaN>
#       AUTHOR: Teoric <code.teoric@gmail.com>
#      VERSION: 0.2
#      CREATED: 2011-08-23 15:35:01 (CEST)
#  Last Change: 2017-06-02, 19:24:55 CEST
#======================================================================

BEGIN {
    push @INC, ".";
}
use strict;
use warnings;
use utf8;
# binmode(STDIN,":utf8");
# binmode(STDERR,":utf8");
# binmode(STDOUT,":utf8");
use open qw( :encoding(UTF-8) :std );

# only if DATA is used:
# binmode(DATA, ":encoding(UTF-8)");

# use charnames qw( :full :short );
use feature qw(say state switch unicode_strings);
use autodie;
use open qw( :encoding(UTF-8) :std );
use IO::Handle;

use GutenbergDE qw(do_book);
use Getopt::Long::Descriptive;

my ($opt, $usage) = describe_options(
    "$0 %o [<file>]",
    [ 'help|h',       "print usage message and exit" ],
    [ 'nr|number|n=i', "number of book in URL",
        { required => 1 , },
    ],
    [ 'title|t=s', "title of the book", 
        { required => 1 , },
    ],
    [ 'chapters|c=i', "number of chapters (default: 1)",
        { default => 1 , },
    ],
    [ 'xml', "output XML (default: HTML)",
    ],
    [ 'directory|dir|d=s', "output directory (default: DATA)",
        { default => "DATA" , },
    ],
);

say STDERR "Text: ", $$opt{title};
GutenbergDE::init_dir($$opt{directory});

do_book($opt);

__END__


