package Text::Same::TextUI;

use Exporter;
@ISA = qw( Exporter );
@EXPORT = qw( draw_with_context );

use warnings;
use strict;
use Carp;

use Text::Same::ChunkedSource;

sub draw_with_context
{
  my $options = shift;
  my $match = shift;

  my $context_lines = $options->{context_lines} || 3;
  my @sources = ($match->source1, $match->source2);

  my @mins = ($match->min1 - $context_lines,
              $match->min2 - $context_lines);
  my @maxs = ($match->max1 + $context_lines,
              $match->max2 + $context_lines);
  for (@mins) {
    $_ = 0 if $_ < 0;
  }
  for (0..1) {
    if ($maxs[$_] > $sources[0]->get_all_chunks - 1) {
      $maxs[$_] = scalar($sources[1]->get_all_chunks) - 1;
    }
  }

  my @source1_chunks = ($sources[0]->get_all_chunks)[$mins[0]..$maxs[0]];
  my @source2_chunks = ($sources[1]->get_all_chunks)[$mins[1]..$maxs[1]];

  return ("match " . $match->to_string . "\n" .
          (join "\n", map {"   " . $_->text} @source1_chunks) .
          "\n=== matches\n" .
          (join "\n", map {"   " . $_->text} @source2_chunks) .
          "\n");
}

1;
