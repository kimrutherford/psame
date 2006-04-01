=head1 NAME

Text::Same::Match

=head1 DESCRIPTION

Objects of this class represent a source of chunks (generally lines)
in one file and a group of chunks in another.  The "chunks" could
potentially be paragraphs or sentences.

=head1 SYNOPSIS

my $source = new Text::Same::ChunkedSource(chunks->\@chunks)

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

package Text::Same::ChunkedSource;

use warnings;
use strict;
use Carp;

use Text::Same::Chunk;

use Digest::MD5 qw(md5);

=head2 new

 Title   : new
 Usage   : $source = new Text::Same::ChunkedSource(chunks->\@chunks)
 Function: Creates a new ChunkedSource object from an array
 Returns : A Text::Same::ChunkedSource object
 Args    : chunks - an array of strings

=cut

sub new
{
  my $arg  = shift;
  my $class = ref($arg) || $arg;

  my $self = {};

  my %params = @_;

  $self->{name} = $params{name};
  $self->{all_chunks} = $params{chunks};
  $self->{all_chunks_count} = scalar(@{$params{chunks}});

  return bless $self, $class;
}

=head2 name

Title   : name
Usage   : my $name = $source->name();
Function: return the name of this source - generally the filename

=cut

sub name
{
  my $self = shift;
  return $self->{name};
}

=head2 hash

 Title   : hash
 Usage   : my $hash_value = hash($options, $text)
 Function: return an integer hash/checksum for the given text

=cut

sub hash
{
  my $options = shift;
  my $text = shift;

  if ($options->{ignore_case}) {
    $text = lc $text;
  }
  if ($options->{ignore_space}) {
    $text =~ s/^\s+//;
    $text =~ s/\s+/ /g;
    $text =~ s/\s+$//;
  }
  return md5($text);
}

=head2 get_all_chunks

 Title   : get_all_chunks
 Usage   : $all_chunks = $source->get_all_chunks;
 Function: return (in order) the chunks from this source

=cut

sub get_all_chunks
{
  my $self = shift;
  return @{$self->{all_chunks}};
}

sub get_chunk_by_indx
{
  my $self = shift;
  my $chunk_indx = shift;
  return $self->{all_chunks}[$chunk_indx];
}

=head2 get_all_chunks_count

 Title   : get_all_chunks_count
 Usage   : $count = $source->get_all_chunks_count;
 Function: return the number of chunks in this source

=cut

sub get_all_chunks_count
{
  my $self = shift;
  return $self->{all_chunks_count};
}

sub _make_chunk_maps
{
  my $self = shift;
  my $options = shift;

  my @filtered_chunk_indexes = ();
  my %filtered_hash = ();
  my %real_index_to_filtered_index = ();
  my %filtered_index_to_real_index = ();

  my $filtered_chunk_count = 0;

  for (my $i = 0; $i < scalar(@{$self->{all_chunks}}); $i++) {
    my $chunk = $self->{all_chunks}[$i];
    if (!($options->{ignore_blanks} && $chunk =~ m!^\s*$!) &&
        !_is_simple($options, $chunk)) {
      push @filtered_chunk_indexes, $i;
      $real_index_to_filtered_index{$i} = $filtered_chunk_count;
      $filtered_index_to_real_index{$filtered_chunk_count} = $i;

      push @{$filtered_hash{hash($options, $chunk)}}, $i;
      $filtered_chunk_count++;
    }
  }

  return \@filtered_chunk_indexes, \%filtered_hash,
         \%real_index_to_filtered_index, \%filtered_index_to_real_index;
}

sub _is_simple($$)
{
  my ($options, $text) = @_;
  if ($options->{ignore_simple}) {
    my $simple_len = $options->{ignore_simple};
    $text =~ s/\s+//g;
    if (length $text <= $simple_len) {
      return 1;
    }
  }
  return 0;
}


sub _get_map_key_from_options
{
  my $self = shift;
  my $options = shift;

  if (!defined $options) {
    carp("\$options is undefined");
  }

  return
    ("key_" .
     ($options->{ignore_case} ? "w" : "W") . "_" .
     ($options->{ignore_blanks} ? "b" : "B") . "_" .
     ($options->{ignore_case} ? "i" : "I") . "_" .
     ($options->{ignore_simple} ? $options->{ignore_simple} : "0"));
}

sub _maybe_make_filtered_maps
{
  my $self = shift;
  my $options = shift;

  my $key = $self->_get_map_key_from_options($options);

  if (!exists $self->{filtered_chunk_indexes}{$key}) {
    ($self->{filtered_chunk_indexes}{$key},
     $self->{filtered_hash}{$key},
     $self->{real_to_filtered}{$key},
     $self->{filtered_to_real}{$key}) = $self->_make_chunk_maps($options);

  }
}

=head2 get_filtered_chunk_indexes

 Title   : get_filtered_chunk_indexes
 Usage   : $filtered_chunk_indexes = $source->get_filtered_chunk_indexes($options);
 Function: return (in order) the chunks from this source that match the given
           options:
            ignore_case=> (0 or 1)    -- ignore case when comparing
            ignore_blanks=> (0 or 1)  -- ignore blank lines when comparing
            ignore_space=> (0 or 1)   -- ignore whitespace in chunks
=cut

sub get_filtered_chunk_indexes
{
  my $self = shift;
  my $options = shift;

  my $key = $self->_get_map_key_from_options($options);

  $self->_maybe_make_filtered_maps($options);

  return $self->{filtered_chunk_indexes}{$key};
}

=head2 get_matching_chunk_indexes

 Title   : get_matching_chunk_indexes
 Usage   : $matches = $source->get_matching_chunk_indexes($options, $text);
 Function: return (in order) the chunks from this source that match the given
           text.
           options:
            ignore_case=> (0 or 1)    -- ignore case when comparing
            ignore_blanks=> (0 or 1)  -- ignore blank lines when comparing
            ignore_space=> (0 or 1)   -- ignore whitespace in chunks
=cut

sub get_matching_chunk_indexes
{
  my $self = shift;
  my $options = shift;
  my $text = shift;

  my $key = $self->_get_map_key_from_options($options);

  $self->_maybe_make_filtered_maps($options);

  my $chunk_hash = $self->{filtered_hash}{$key};

  return @{$chunk_hash->{hash($options, $text)} || []};
}

=head2 get_filtered_indx_from_real

 Title   : get_filtered_indx_from_real
 Usage   : $indx = $source->get_filtered_indx_from_real($options, $real_indx);
 Function: for the given index (eg. line number) in this source, return the
           corresponding index in the list of chunks generated by applying the
           $options.  For example if $options->{ignore_blanks} is true the
           filtered chunks will contain no blank lines.

eg. input lines:

   some text on line 0
   <blank line>
   <blank line>
   some text on line 3

the real index of "some text on line 3" is 3, but the filtered index is 1 if
ignore_blanks is set because the filtered lines are:
   some text on line 0
   some text on line 3

=cut

sub get_filtered_indx_from_real
{
  my $self = shift;
  my $options = shift;
  my $real_indx = shift;

  my $key = $self->_get_map_key_from_options($options);

  $self->_maybe_make_filtered_maps($options);

  return $self->{real_to_filtered}{$key}{$real_indx};
}

=head2 get_real_indx_from_filtered

 Title : get_real_indx_from_filtered
 Usage : $indx = $source->get_real_indx_from_filtered($options, $filtrd_indx);
 Func  : return the real index in the source that cooresponds to the given
         filtered index.  See discussion above.

=cut

sub get_real_indx_from_filtered
{
  my $self = shift;
  my $options = shift;
  my $filtered_indx = shift;

  my $key = $self->_get_map_key_from_options($options);

  $self->_maybe_make_filtered_maps($options);

  return $self->{real_to_filtered}{$key}{$filtered_indx};
}

=head2 get_previous_chunk_indx

 Title   : get_previous_chunk_indx
 Usage   : $prev_chunk_indx =
               $source->get_previous_chunk_indx($options, $chunk_indx);
 Function: return the previous chunk index from the list of filtered chunk
           indexes (for the given $options).  See discussion above.

=cut

sub get_previous_chunk_indx
{
  my $self = shift;
  my $options = shift;
  my $chunk_indx = shift;

  my $prev_filtered_indx =
    $self->get_filtered_indx_from_real($options, $chunk_indx) - 1;

  if ($prev_filtered_indx < 0) {
    return undef;
  }

  return ($self->get_filtered_chunk_indexes($options))->[$prev_filtered_indx];
}

1;
