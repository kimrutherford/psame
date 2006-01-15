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

  my $min1 = $match->min1;
  my $max1 = $match->max1;
  my $min2 = $match->min2;
  my $max2 = $match->max2;

  my $width = $options->{term_width};

  my $half_width = int($width / 2 - 6);

  my $ret = "match " . ($min1+1) . ".." . ($max1+1) . "==" .
            ($min2+1) . ".." . ($max1+1) . "\n";

  my @start_context1 = _get_start_context($options, $min1, $match->source1);
  my @start_context2 = _get_start_context($options, $min2, $match->source2);
  my $max_start_context_len =
    scalar(@start_context1) > scalar(@start_context2) ?
      scalar(@start_context1) : scalar(@start_context2);

  my $context_format_str =
    "  %-${half_width}.${half_width}s   %-${half_width}.${half_width}s\n";
  my $match_format_str =
    "  %-${half_width}.${half_width}s = %-${half_width}.${half_width}s\n";
  my $i;
  for ($i = 0; $i < $max_start_context_len; $i++) {
    if (defined $start_context1[$i] || defined $start_context2[$i]) {
      $ret .= sprintf $context_format_str,
        (defined $start_context1[$i] ? $start_context1[$i] : ""),
        (defined $start_context2[$i] ? $start_context2[$i] : "");
    }
  }

  my @match_chunks1 = _get_match_chunks($options, $min1, $max1,
                                        $match->source1);
  my @match_chunks2 = _get_match_chunks($options, $min2, $max2,
                                        $match->source2);
  my $max_match_len =
    scalar(@match_chunks1) > scalar(@match_chunks2) ?
      scalar(@match_chunks1) : scalar(@match_chunks2);

  for ($i = 0; $i < $max_match_len; $i++) {
    $ret .= sprintf $match_format_str,
      (defined $match_chunks1[$i] ? $match_chunks1[$i] : ""),
      (defined $match_chunks2[$i] ? $match_chunks2[$i] : "");
  }

  my @end_context1 = _get_end_context($options, $max1, $match->source1);
  my @end_context2 = _get_end_context($options, $max2, $match->source2);
  my $max_end_context_len =
    scalar(@end_context1) > scalar(@end_context2) ?
      scalar(@end_context1) : scalar(@end_context2);

  for ($i = 0; $i < $max_end_context_len; $i++) {
    if (defined $end_context1[$i] || defined $end_context2[$i]) {
      $ret .= sprintf $context_format_str,
        (defined $end_context1[$i] ? $end_context1[$i] : ""),
        (defined $end_context2[$i] ? $end_context2[$i] : "");
    }
  }


  return $ret;
}

sub _get_match_chunks
{
  my ($options, $min, $max, $source) = @_;

  my @ret = ();

  for (my $i = $min; $i <= $max; $i++) {
    push @ret, ($source->get_all_chunks)[$i]->text;
  }

  return @ret;
}

sub _get_start_context
{
  my ($options, $min, $source) = @_;

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
  my ($options, $max, $source) = @_;

  my $context_chunks = $options->{context} || 3;
  my $context_max = $max + $context_chunks;

  my @ret = ();

  for (my $i = $max + 1; $i < $context_max; $i++) {
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
  my ($options, $match) = @_;

  my $ret = "match " . $match->to_string . "\n";

  $ret .= _draw_range_and_context($options, $match->min1, $match->max1,
                                 $match->source1);
  $ret .= "=== matches\n";

  $ret .= _draw_range_and_context($options, $match->min2, $match->max2,
                                 $match->source2);

}

sub _draw_range_and_context
{
  my ($options, $min, $max, $source) = @_;

  my $ret = "";

  for my $start_chunk_text (_get_start_context($options, $min, $source)) {
    if (defined $start_chunk_text) {
      $ret .= "   $start_chunk_text\n";
    }
  }

  for (my $i = $min; $i <= $max; $i++) {
    my $match_chunk_text = ($source->get_all_chunks)[$i]->text;
    $ret .= "=  $match_chunk_text\n";
  }

  for my $end_chunk_text (_get_end_context($options, $max, $source)) {
    if (defined $end_chunk_text) {
      $ret .= "   $end_chunk_text\n";
    }
  }

  return $ret;
}

1;
