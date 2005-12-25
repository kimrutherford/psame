package Text::Same;

$VERSION = 0.01;

=head1 NAME

Text::Same - Look for similarities between files

=head1 SYNOPSIS

    use Text::Same;

    ## Mix and match filenames, strings, file handles, producer subs,
    ## or arrays of records; returns an array of matches
    my @same = same "file1.txt", "file2.txt", { ignore-whitespace => 1 };
    my @same = same \$string1,   \$string2,   \%options;
    my @same = same \*FH1,       \*FH2;
    my @same = same \&reader1,   \&reader2;
    my @same = same \@records1,  \@records2;

    ## May also mix input types:
    my @same = same \@records1,  "file_B.txt";

    ...

=head1 DESCRIPTION

C<same()> compares two files or strings and returns an array of Text::Same::Match
objects.

=cut


=head1 FUNCTIONS

=cut


use Exporter;
@ISA = qw( Exporter );
@EXPORT = qw( same );

use warnings;
use strict;
use Carp;

use Text::Same::Process;

our $VERSION = '0.01';

sub same {
  my @seqs = ( shift, shift );
  my $options = shift || {};

  for my $i ( 0..1 ) {
    my $seq = $seqs[$i];
    my $type = ref $seq;

    while ( $type eq "CODE" ) {
      $seqs[$i] = $seq = $seq->( $options );
      $type = ref $seq;
    }

    my $AorB = !$i ? "A" : "B";

    if ( $type eq "ARRAY" ) {
      # good!
    }
    elsif ( $type eq "SCALAR" ) {
      $seqs[$i] = [split( /^/m, $$seq )];
    }
    elsif ( ! $type ) {
      local $/ = "\n";
      open F, "<$seq" or carp "$!: $seq";
      $seqs[$i] = [<F>];
      close F;
    }
    elsif ( $type eq "GLOB" || UNIVERSAL::isa( $seq, "IO::Handle" ) ) {
      local $/ = "\n";
      $seqs[$i] = [<$seq>];
    }
    else {
      confess "Can't handle input of type ", ref;
    }
  }

  return Text::Same::Process->process(@seqs);
}






=head1 ACKNOWLEDGEMENTS

Most of this code came from Text::Diff.

=head1 AUTHOR

Kim Rutherford, C<< <kmr at xenu.org.uk> >>

=head1 COPYRIGHT & LICENSE

Copyright 2005 Kim Rutherford, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

1;
