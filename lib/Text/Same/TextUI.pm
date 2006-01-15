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

sub _draw_match_side_by_side
{
  my $options = shift;
  my $match = shift;

  my $ret = "match " . $match->to_string . "\n";

  my $start_context1 = _get_start_context($options, $match->min1, $match->source1);
  my $start_context2 = _get_start_context($options, $match->min2, $match->source2);

  my $end_context1 = _get_end_context($options, $match->max1, $match->source1);
  my $end_context2 = _get_end_context($options, $match->max2, $match->source2);


}

sub _get_start_context
{
  my $options = shift;
  my $min = shift;
  my $source = shift;

  my $context_chunks = $options->{context} || 3;
  my $context_min = $min - $context_chunks;

  my @ret = ();

  for (my $i = $context_min; $i < $min; $i++) {
    if ($i < 0) {
      push @ret, undef;
    } else {
      push @ret, ($source->get_all_chunks)[$i]->text;
    }
  }

  return @ret;
}

sub _get_end_context
{
  my $options = shift;
  my $max = shift;
  my $source = shift;

  my $context_chunks = $options->{context} || 3;
  my $context_max = $max + $context_chunks;

  my @ret = ();

  for (my $i = $max; $i < $context_max; $i++) {
    if ($i > $source->get_all_chunks_count - 1) {
      push @ret, undef;
    } else {
      push @ret, ($source->get_all_chunks)[$i]->text;
    }
  }

  return @ret;
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

  my $ret = "";

  for my $chunk_text (_get_start_context($options, $min, $source)) {
    if (defined $chunk_text) {
      $ret .= "   $chunk_text\n";
    }
  }

  for (my $i = $min; $i <= $max; $i++) {
    my $chunk_text = ($source->get_all_chunks)[$i]->text;
    $ret .= "=  $chunk_text\n";
  }

  for my $chunk_text (_get_end_context($options, $max, $source)) {
    if (defined $chunk_text) {
      $ret .= "   $chunk_text\n";
    }
  }

  return $ret;
}

1;
