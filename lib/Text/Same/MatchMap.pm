package Text::Same::MatchMap;

use warnings;
use strict;
use Carp;

sub new
{
  my $arg  = shift;
  my $class = ref($arg) || $arg;

  my $self = {@_};

  my $source1 = %{$self->{source1}};
  my $source2 = %{$self->{source2}};
  my %seen_pairs = %{$self->{seen_pairs}};

  my @matches = values %seen_pairs;
  my %uniq_matches = ();

  for my $match (@matches) {
    my @ranges = $match->ranges;
    $uniq_matches{"@ranges"} = $match;
  }

  $self->{matches} = [values %uniq_matches];

  bless $self, $class;

#  $self->_find_unmatched_chunks();

  return $self;
}

# sub _find_matched_ranges
# {
#   my $self = shift;
#   my @matches = $self->matches;

#   my %indx_to_matches1 = ();
#   my %indx_to_matches2 = ();

#   for my $match (@matches) {
#     my $i;
#     for ($i = $match->min1; $i <= $match->max1; ++$i) {
#       push @{$indx_to_matches1{$i}}, $match;
#     }
#     for ($i = $match->min2; $i <= $match->max2; ++$i) {
#       push @{$indx_to_matches2{$i}}, $match;
#     }
#   }

#   $self->{non_matches1} = _get_non_matches($source1, \%indx_to_matches1);
#   $self->{non_matches2} = _get_non_matches($source2, \%indx_to_matches2);
# }

# sub _get_non_matches
# {
#   my $source = shift;
#   my $indx_to_matches_ref = shift;
#   my %indx_to_matches = %{$indx_to_matches_ref};

#   my $max_chunk_
# }

sub matches
{
  my $self = shift;
  return @{$self->{matches}};
}

sub non_matches1
{
  my $self = shift;
  return @{$self->{non_matches1}};

}

sub non_matches2
{
  my $self = shift;
  return @{$self->{non_matches2}};
}

1;
