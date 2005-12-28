package Text::Same::Process;

use warnings;
use strict;
use Carp;

use Text::Same::Match;
use Text::Same::Chunk;
use Text::Same::ChunkPair;
use Text::Same::MatchMap;
use Text::Same::Cache;

sub process_hits($\%\@\@\@)
{
  my ($this_chunk, $seen_pairs_ref, $matching_chunks_ref,
      $this_chunk_array_ref, $other_chunk_array_ref) = @_;

  for my $other_chunk (@$matching_chunks_ref) {
    my $chunk_pair = new Text::Same::ChunkPair($this_chunk, $other_chunk);
    my $pair_string = $chunk_pair->to_string();

    if (!exists $seen_pairs_ref->{$pair_string}) {
      my $this_chunk_indx = $this_chunk->indx;
      my $other_chunk_indx = $other_chunk->indx;

      if ($this_chunk_indx > 0 && $other_chunk_indx > 0) {
        my $this_prev_chunk = $this_chunk_array_ref->[$this_chunk_indx-1];
        my $other_prev_chunk = $other_chunk_array_ref->[$other_chunk_indx-1];

        if ($this_prev_chunk->hash() == $other_prev_chunk->hash()) {
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

sub find_matches($$)
{
  my ($source1, $source2) = @_;

  my @ca1 = $source1->get_all_chunks;
  my %ch1 = $source1->get_chunk_hash;
  my @ca2 = $source2->get_all_chunks;
  my %ch2 = $source2->get_chunk_hash;

#  print STDERR "source1: ", %$source1,"\n";
#  print STDERR "@ca1 -=- @ca2\n";
#  print STDERR "source2: ", %$source2,"\n";
#  print STDERR "@ca1 -=- @ca2\n";


  my %seen_pairs = ();

  for my $this_chunk (@ca1) {
    my $matching_chunks_ref = $ch2{$this_chunk->text};

    if (defined $matching_chunks_ref) {
      my @matching_chunks = @$matching_chunks_ref;

      process_hits($this_chunk, %seen_pairs, @matching_chunks, @ca1, @ca2);
    }
  }

  return \%seen_pairs;
}

sub process
{
  my ($self, $ar1, $ar2) = @_;

  my $cache = new Text::Same::Cache();

  my $source1 = $cache->get($ar1);
  my $source2 = $cache->get($ar2);

  my $seen_pairs_ref = find_matches $source1, $source2;

  return new Text::Same::MatchMap(source1=>$source1, source2=>$source2,
                                  seen_pairs=>$seen_pairs_ref);
}

1;
