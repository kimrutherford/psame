package Text::Same::MatchMap;

use warnings;
use strict;
use Carp;

sub new
{
  my $self  = shift;
  my $class = ref($self) || $self;

  return bless {@_}, $class;
}

sub matches
{
  my $self = shift;
  return @{$self->{matches}};
}

1;
