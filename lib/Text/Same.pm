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
@EXPORT = qw( compare find );

use warnings;
use strict;
use Carp;

use Text::Same::Match;
use Text::Same::Chunk;
use Text::Same::ChunkPair;
use Text::Same::MatchMap;
use Text::Same::Cache;

our $VERSION = '0.01';

sub _process_hits($$\%\@$$)
{
  my ($options, $this_chunk, $seen_pairs_ref, $matching_chunks_ref,
      $this_chunked_source, $other_chunked_source) = @_;

  for my $other_chunk (@$matching_chunks_ref) {
    my $chunk_pair = new Text::Same::ChunkPair($this_chunk, $other_chunk);
    my $pair_string = $chunk_pair->to_string();

    if (!exists $seen_pairs_ref->{$pair_string}) {
      my $this_chunk_indx = $this_chunk->indx;
      my $other_chunk_indx = $other_chunk->indx;

      if ($this_chunk_indx > 0 && $other_chunk_indx > 0) {
        my $this_prev_chunk = $this_chunked_source->get_previous_chunk;
        my $other_prev_chunk = $other_chunked_source->get_previous_chunk;

        my $this_hash = Text::Same::ChunkedSource::hash($options, $this_prev_chunk);
        my $other_hash = Text::Same::ChunkedSource::hash($options, $other_prev_chunk);

        if ($this_hash = $other_hash) {
          my $prev_pair = $this_prev_chunk->indx . "_" . $other_prev_chunk->indx;
          my $prev_match =  $seen_pairs_ref->{$prev_pair};

          if (defined $prev_match) {
            $prev_match->add($chunk_pair);
            $seen_pairs_ref->{$pair_string} = $prev_match;
            next;
          }
        }
      }
      my $match = new Text::Same::Match($chunk_pair);
      $seen_pairs_ref->{$pair_string} = $match;
    }
  }
}

sub _find_matches($$$)
{
  my ($options, $source1, $source2) = @_;

  my @source1_chunk_array = $source1->get_filtered_chunks($options);

  my %seen_pairs = ();

  for my $this_chunk (@source1_chunk_array) {
    my @matching_chunks = 
      $source2->get_matching_chunks($options, $this_chunk->text);

    if (@matching_chunks) {
      my @matching_chunks = @matching_chunks;

      _process_hits($options, $this_chunk, %seen_pairs, @matching_chunks,
                    $source1, $source2);
    }
  }

  return \%seen_pairs;
}

sub compare {
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

  my $cache = new Text::Same::Cache();

  my $source1 = $cache->get($seqs[0], $options);
  my $source2 = $cache->get($seqs[1], $options);

  my $seen_pairs_ref = _find_matches $options, $source1, $source2;

  return new Text::Same::MatchMap(options=>$options, source1=>$source1,
                                  source2=>$source2,
                                  seen_pairs=>$seen_pairs_ref);
}


sub find
{

}

=head1 ACKNOWLEDGEMENTS

Most of this code came from Text::Diff.

=head1 AUTHOR

Kim Rutherford, C<< <kmr at xenu.org.uk> >>

=head1 COPYRIGHT & LICENSE

Copyright 2005 Kim Rutherford, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;

