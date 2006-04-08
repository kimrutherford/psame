=head1 NAME

Text::Same::ChunkPair

=head1 DESCRIPTION

A class representing a pair of chunk indexes (ie. line numbers)

=head1 SYNOPSIS

  my $pair = new Text::Same::ChunkPair($chunk_index1, $chunk_index2);

=head1 METHODS

See below.  Methods private to this module are prefixed by an
underscore.

=cut

package Text::Same::ChunkPair;

use warnings;
use strict;
use Carp;

use vars qw($VERSION);
$VERSION = '0.01';

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
    die "ChunkPair constructor needs 2 integer arguments\n";
  }

  if (!defined $_[0] || !defined $_[1]) {
    croak "undefined value passed to ChunkPair->new\n";
  }

  my $packed_pair = make_packed_representation(@_);

  return bless \$packed_pair, $class;
}

=head2 chunk_index1

 Title   : chunk_index1
 Usage   : my $chunk_index = $match->chunk_index1;
 Function: return the first Chunk_index of this ChunkPair
 Args    : none

=cut

sub chunk_index1
{
  my $self = shift;
  return (unpack 'II', $$self)[0];
}

=head2 chunk_index2

 Title   : chunk_index2
 Usage   : my $chunk_index = $match->chunk_index2;
 Function: return the second chunk_index of this ChunkPair
 Args    : none

=cut

sub chunk_index2
{
  my $self = shift;
  return (unpack 'II', $$self)[1];
}

sub packed_representation
{
  my $self = shift;
  return $$self;
}

sub make_packed_representation
{
  return pack 'II', @_;
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
  return $self->chunk_index1 . "<->" . $self->chunk_index2;
}

=head1 AUTHOR

Kim Rutherford <kmr+same@xenu.org.uk>

=head1 COPYRIGHT & LICENSE

Copyright 2005,2006 Kim Rutherford.  All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 DISCLAIMER

This module is provided "as is" without warranty of any kind. It
may redistributed under the same conditions as Perl itself.

=cut

1;
