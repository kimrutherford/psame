=head1 NAME

Text::Same::ChunkPair

=head1 DESCRIPTION

A class representing a pair of Chunk objects

=head1 SYNOPSIS

  my $pair = new Text::Same::ChunkPair($chunk1, $chunk2);

=head1 METHODS

See below.  Methods private to this module are prefixed by an
underscore.

=head1 AUTHOR

Kim Rutherford <kmr+same@xenu.org.uk>

=head1 COPYRIGHT

Copyright (C) 2005, 2006 Kim Rutherford. All Rights Reserved.

=head1 DISCLAIMER

This module is provided "as is" without warranty of any kind. It
may redistributed under the same conditions as Perl itself.

=cut

package Text::Same::ChunkPair;

use warnings;
use strict;
use Carp;

=head2 new

 Title   : new
 Usage   : $pair = new Text::Same::ChunkPair($chunk1, $chunk2);
 Function: Creates a new ChunkPair object from two Chunk objects
 Returns : A Text::Same::ChunkPair object
 Args    : two Chunks

=cut

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

=head2 chunk1

 Title   : chunk1
 Usage   : my $chunk = $match->chunk1;
 Function: return the first Chunk of this ChunkPair
 Args    : none

=cut

sub chunk1
{
  my $self = shift;
  return $self->[0];
}

=head2 chunk2

 Title   : chunk2
 Usage   : my $chunk = $match->chunk2;
 Function: return the second Chunk of this ChunkPair
 Args    : none

=cut

sub chunk2
{
  my $self = shift;
  return $self->[1];
}

=head2 as_string

 Title   : as_string
 Usage   : my $str = $match->as_string
 Function: return a string representation of this ChunkPair
 Args    : none

=cut

sub as_string
{
  my $self = shift;
  return $self->[0]->indx . "_" . $self->[1]->indx;
}

1;


