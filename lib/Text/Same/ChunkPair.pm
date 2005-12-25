package Text::Same::ChunkPair;

use warnings;
use strict;
use Carp;

sub new
{
  my $self  = shift;
  my $class = ref($self) || $self;

  if (scalar(@_) != 2) {
    die "ChunkPair constructor needs 2 arguments\n";
  }

  if (!defined $_[0] || !defined $_[1]) {
    croak "undefined value passed to ChunkPair->new\n";
  }

  if (!ref $_[0] || !ref $_[1]) {
    croak "non-Chunks passed to ChunkPair->new\n";
  }

  return bless [@_], $class;
}

sub chunk1
{
  my $self = shift;
  return $self->[0];
}

sub chunk2
{
  my $self = shift;
  return $self->[1];
}

sub to_string
{
  my $self = shift;
  return $self->[0]->indx . "_" . $self->[1]->indx;
}

1;


