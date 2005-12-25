package Text::Same::Process;

use warnings;
use strict;
use Carp;

use Text::Same::Match;
use Text::Same::Chunk;
use Text::Same::ChunkPair;

sub get_chunk_hash
{
  my %ret_hash = ();

  for (my $i = 0; $i < @_; ++$i) {
    my $chunk_text = $_[$i];
    push @{$ret_hash{$chunk_text}}, new Text::Same::Chunk(text=>$chunk_text, indx=>$i);
  }

  return %ret_hash;
}

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

sub find_matches(\@\%\@\%)
{
  my ($car1, $chr1, $car2, $chr2) = @_;

  my @ca1 = @$car1;
  my %ch1 = %$chr1;
  my @ca2 = @$car2;
  my %ch2 = %$chr2;

  my %seen_pairs = ();

  for my $this_chunk (@ca1) {
    my $matching_chunks_ref = $ch2{$this_chunk->text};

    if (defined $matching_chunks_ref) {
      my @matching_chunks = @$matching_chunks_ref;

      process_hits($this_chunk, %seen_pairs, @matching_chunks, @ca1, @ca2);
    }
  }

  my @matches = values %seen_pairs;
  my %uniq_matches = ();

  for my $match (@matches) {
    my @ranges = $match->ranges;
    $uniq_matches{"@ranges"} = $match;
  }

  return values %uniq_matches;
}

sub make_chunks
{
  my @chunks_text = @_;

  my @ret = ();

  for (my $i = 0; $i < scalar(@chunks_text); ++$i) {
    push @ret, new Text::Same::Chunk(text=>$chunks_text[$i], indx=>$i);
  }

  return @ret;
}


sub process
{
  my ($self, $ar1, $ar2) = @_;

  my @chunks1 = make_chunks(@$ar1);
  my @chunks2 = make_chunks(@$ar2);

  my %ch1 = get_chunk_hash(@$ar1);
  my %ch2 = get_chunk_hash(@$ar2);

  return find_matches @chunks1, %ch1, @chunks2, %ch2;
}

1;
