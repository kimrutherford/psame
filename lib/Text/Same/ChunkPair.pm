=head1 NAME

Text::Same::ChunkPair

=head1 DESCRIPTION

A class representing a pair of chunk indexes

=head1 SYNOPSIS

  my $pair = new Text::Same::ChunkPair($chunk_index1, $chunk_index2);

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
 Usage   : $pair = new Text::Same::ChunkPair($chunk_index1, $chunk_index2);
 Function: Creates a new ChunkPair object from two chunk indexes
 Returns : A Text::Same::ChunkPair object
 Args    : two chunk indexes

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

  return bless [@_], $class;
}

=head2 chunk_index1

 Title   : chunk_index1
 Usage   : my $chunk_index = $match->chunk_index1;
 Function: return the first Chunk_Index of this ChunkPair
 Args    : none

=cut

sub chunk_index1
{
  my $self = shift;
  return $self->[0];
}

=head2 chunk_index2

 Title   : chunk_index2
 Usage   : my $chunk_index = $match->chunk_index2;
 Function: return the second chunk_Index of this ChunkPair
 Args    : none

=cut

sub chunk_index2
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
  return $self->[0] . "<->" . $self->[1];
}

1;


