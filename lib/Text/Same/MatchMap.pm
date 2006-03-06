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

  my @sorted_matches =
    sort {
      $a->min1 <=> $b->min1
        ||
      $a->min2 <=> $b->min2;
    } values %uniq_matches;

  $self->{matches} = \@sorted_matches;

  bless $self, $class;

  $self->_find_unmatched_chunks($self->{source1}, $self->{source2});

  return $self;
}

sub source1
{
  my $self = shift;
  return $self->{source1};
}

sub source2
{
  my $self = shift;
  return $self->{source2};
}

sub _find_matched_ranges
{
  my $self = shift;
  my @matches = $self->matches;

  my %indx_to_matches1 = ();
  my %indx_to_matches2 = ();

  for my $match (@matches) {
    my $i;
    for ($i = $match->min1; $i <= $match->max1; ++$i) {
      push @{$indx_to_matches1{$i}}, $match;
    }
    for ($i = $match->min2; $i <= $match->max2; ++$i) {
      push @{$indx_to_matches2{$i}}, $match;
    }
  }

  return (\%indx_to_matches1, \%indx_to_matches2);
}

sub _find_unmatched_chunks
{
  my $self = shift;
  my $source1 = shift;
  my $source2 = shift;

  my ($indx_to_matches1, $indx_to_matches2) = $self->_find_matched_ranges();

  $self->{source1_non_matches} = _get_non_matches($source1, $indx_to_matches1);
  $self->{source2_non_matches} = _get_non_matches($source2, $indx_to_matches2);
}

sub _get_non_matches
{
   my $source = shift;
   my $indx_to_matches_ref = shift;
   my %indx_to_matches = %{$indx_to_matches_ref};
   my @non_matches = ();
   my $max_chunk = $source->get_all_chunks_count;
   my $current_min = undef;

   if ($max_chunk == 0) {
     return [];
   }

   if (!exists $indx_to_matches{0}) {
     $current_min = 0;
   }

   for (my $i = 1; $i < $max_chunk; $i++) {
     if (defined $current_min) {
       if (exists $indx_to_matches{$i}) {
         push @non_matches, {start=>$current_min, end=>$i-1};
         $current_min = undef;
       }
     } else {
       if (!exists $indx_to_matches{$i}) {
         $current_min = $i;
       }
     }
   }

   return \@non_matches;
}

sub matches
{
  my $self = shift;
  return @{$self->{matches}};
}

sub source1_non_matches
{
  my $self = shift;
  return @{$self->{source1_non_matches}};
}

sub source2_non_matches
{
  my $self = shift;
  return @{$self->{source2_non_matches}};
}

1;
