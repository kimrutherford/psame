=head1 NAME

Text::Same::Match

=head1 DESCRIPTION

Objects of this class represent a match between a group of lines in one file 
to group of lines in another.

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

package Text::Same::Match;

use warnings;
use strict;
use Carp;

=head2 new

 Title   : new
 Usage   : $match = new Text::Same::Match(@pairs)
 Function: Creates a new Match object from an array of ChunkPair objects
 Returns : An Text::Same::Match object
 Args    : an array of ChunkPair objects

=cut

sub new
{
  my $self  = shift;
  my $class = ref($self) || $self;

  my $ret = {};

  $ret->{pairs} = [@_];

  $ret->{min1} = 999999999999;
  $ret->{max1} = -1;
  $ret->{min2} = 999999999999;
  $ret->{max2} = -1;

  bless $ret, $class;
  $ret->_update_stats(@_);

  return $ret;
}


=head2 new

Title   : add
Usage   : $match->add(@chunk_pairs);
Function: add ChunkPair objects to this objects - no checks are made that 
          the new ChunkPairs are ajacent to the current pairs
Returns : $self
Args    : an array of ChunkPair objects
=cut
sub add
{
  my $self = shift;
  for my $chunk_pair (@_) {
    $self->_update_stats($chunk_pair);
    push @{$self->{pairs}}, $chunk_pair;
  }
  $self;
}

sub _update_stats
{
  my $self = shift;
  my @new_pairs = @_;

  for my $chunk_pair (@new_pairs) {
    my $chunk1 = $chunk_pair->chunk1;
    my $chunk2 = $chunk_pair->chunk2;

    if ($chunk1->indx < $self->{min1}) {
      $self->{min1} = $chunk1->indx;
    }
    if ($chunk1->indx > $self->{max1}) {
      $self->{max1} = $chunk1->indx;
    }
    if ($chunk2->indx < $self->{min2}) {
      $self->{min2} = $chunk2->indx;
    }
    if ($chunk2->indx > $self->{max2}) {
      $self->{max2} = $chunk2->indx;
    }
  }
}


=head2 new

 Title   : add
 Usage   : $match->add(@chunk_pairs);
 Function: add ChunkPair objects to this objects - no checks are made that 
           the new ChunkPairs are ajacent to the current pairs
 Returns : $self
 Args    : an array of ChunkPair objects

=cut
sub min1
{
  return $_[0]->{min1};
}

=head2 min1

 Title   : min1
 Usage   : $match->add(@chunk_pairs);
 Function: add ChunkPair objects to this objects - no checks are made that 
           the new ChunkPairs are ajacent to the current pairs
 Returns : $self
 Args    : an array of ChunkPair objects

=cut
sub max1
{
  return $_[0]->{max1};
}

sub min2
{
  return $_[0]->{min2};
}

sub max2
{
  return $_[0]->{max2};
}

sub ranges
{
  return ($_[0]->{min1}, $_[0]->{max1}, $_[0]->{min2}, $_[0]->{max2});
}

sub pairs
{
  return $_[0]->{pairs};
}

=head2 score

 Title   : score
 Usage   : $acc = $seq->score;
 Function: The score of this Match - longer match gives a higher score
 Returns : int - currently returns the total number of lines this match 
           covers in both files
 Args    : None

=cut
sub score
{
  my $self = shift;
  return $self->{max1} - $self->{min1} + $self->{max2} - $self->{min2} + 2;
}

1;
