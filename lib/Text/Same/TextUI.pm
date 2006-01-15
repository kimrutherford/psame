package Text::Same::TextUI;

use Exporter;
@ISA = qw( Exporter );
@EXPORT = qw( draw_match );

use warnings;
use strict;
use Carp;

use Text::Same::ChunkedSource;

sub draw_match
{
  my $options = shift;
  my $match = shift;

  if ($options->{side_by_side}) {
    _draw_match_side_by_side($options, $match);
  } else {
    _draw_match_vertically($options, $match);
  }
}

sub _draw_match_vertically
{
  my $options = shift;
  my $match = shift;

  my $ret = "match " . $match->to_string . "\n";

  $ret .= _draw_range_and_context($options, $match->min1, $match->max1,
                                 $match->source1);
  $ret .= "=== matches\n";

  $ret .= _draw_range_and_context($options, $match->min2, $match->max2,
                                 $match->source2);

}

sub _draw_range_and_context
{
  my $options = shift;
  my $min = shift;
  my $max = shift;
  my $source = shift;

  my $context_lines = $options->{context_lines} || 3;

  my $context_min = $min - $context_lines;
  if ($context_min < 0) {
    $context_min = 0;
  }
  my $context_max = $max + $context_lines;
  if ($context_max > $source->get_all_chunks - 1) {
    $context_max = scalar($source->get_all_chunks) - 1;
  }

  print "$min $max $context_min $context_max\n";


  my $ret = "";

  for (my $i = $context_min; $i <= $context_max; $i++) {
    my $chunk_text = ($source->get_all_chunks)[$i]->text;
    if ($i < $min || $i > $max) {
      $ret .= "   $chunk_text\n";
    } else {
      $ret .= "=  $chunk_text\n";
    }
  }

  return $ret;
}

1;
