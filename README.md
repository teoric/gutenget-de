# Scripts to fetch texts from Gutenberg-DE

These scripts can be used to fetch/grab e-texts (= ‘books’) from [Gutenberg-DE](http://gutenberg.spiegel.de/).

Texts are saved in subdirectories and contain XML that is mostly XHTML + a tag `<fussnote>` for footnotes, without the boilerplate that surrounds the HTML presentation.

Documentation inside the scripts is in German, as are the texts at Gutenberg-DE. The code is simple, anyway.  

- `GutenbergDE.pm` – [Perl](http://www.perl.org) module, depends on
  [Getopt::Long::Descriptive](http://search.cpan.org/~rjbs/Getopt-Long-Descriptive/lib/Getopt/Long/Descriptive.pm)
and [HTML::TreeBuilder](http://search.cpan.org/~cjm/HTML-Tree/lib/HTML/TreeBuilder.pm)
- `get_gut_mod.pl` – Script for getting a text. See help and code for details.
- `get_kant_mod.pl` – example script for getting Kant's texts.

- - -

Perl-Skripte, um Texte/Bücher von [Gutenberg-DE](http://gutenberg.spiegel.de/) herunterzuladen.

Die Texte werden als XTHML (zuzüglich eines Tags `<fussnote>` für Fußnoten) gespeichert; es wird nur der Text-Bereich der Gutenberg-DE-Seiten erfasst.
