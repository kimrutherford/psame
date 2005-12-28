package Text::Same::Range;

use warnings;
use strict;
use Carp;

sub new
{
  my $self  = shift;
  my $class = ref($self) || $self;

  if (scalar(@_) != 2) {
    die "Range constructor needs 2 arguments\n";
  }

  if (!defined $_[0] || !defined $_[1]) {
    croak "undefined value passed to Range->new\n";
  }

  return bless [@_], $class;
}

sub start
{
  my $self = shift;
  return $self->[0];
}

sub end
{
  my $self = shift;
  return $self->[1];
}

sub to_string
{
  my $self = shift;
  return $self->[0] . ".." . $self->[1];
}

1;


