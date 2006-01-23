package Text::Same::Cache;

use warnings;
use strict;
use Carp;

use Text::Same::ChunkedSource;

sub new
{
  my $self  = shift;
  my $class = ref($self) || $self;
  return bless {}, $class;
}

sub get
{
  my $self = shift;
  return new Text::Same::ChunkedSource(chunks=>shift);
}

1;
