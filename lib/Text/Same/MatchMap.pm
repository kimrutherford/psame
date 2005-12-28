package Text::Same::MatchMap;

use warnings;
use strict;
use Carp;

sub new
{
  my $arg  = shift;
  my $class = ref($arg) || $arg;

  my $self = {@_};

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

#   my %line_to_matches1 = ();
#   my %line_to_matches2 = ();

#   for my $match (@matches) {
#     my $i;
#     for ($i = $match->min1; $i <= $match->max1; ++$i) {
#       push @{$line_to_matches1{$i}}, $match;
#     }
#     for ($i = $match->min2; $i <= $match->max2; ++$i) {
#       push @{$line_to_matches2{$i}}, $match;
#     }
#   }
# }

sub matches
{
  my $self = shift;
  return @{$self->{matches}};
}

sub non_matches_1
{
  
}

sub non_matches_2
{
  
}

1;
