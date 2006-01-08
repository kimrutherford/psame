package Text::Same::ChunkedSource;

use warnings;
use strict;
use Carp;

use Text::Same::Chunk;

use String::CRC32;

sub new
{
  my $arg  = shift;
  my $class = ref($arg) || $arg;

  my $self = {};

  my %params = @_;

  $self->{all_chunks} = _make_all_chunks($params{lines});

  return bless $self, $class;
}

sub _make_all_chunks
{
  my @chunks_text = @{$_[0]};
  my @ret = ();

  for (my $i = 0; $i < scalar(@chunks_text); ++$i) {
    push @ret, new Text::Same::Chunk(text=>$chunks_text[$i], indx=>$i);
  }

  return \@ret;
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
  return _hash($text);
}

sub _hash
{
  return crc32(shift);
}

=head2 get_all_chunks

 Title   : get_all_chunks
 Usage   : $chunk->get_all_chunks($params);
 Function: return (in order) the chunks from this source that match the given
           options:
            ignore_case=> (0 or 1)    -- ignore case when comparing
            ignore_blanks=> (0 or 1)  -- ignore blank lines when comparing
            ignore_space=> (0 or 1)   -- ignore whitespace in lines
=cut

sub get_all_chunks
{
  my $self = shift;
  return @{$self->{all_chunks}};
}

sub _make_chunk_maps
{
  my $self = shift;
  my $options = shift;

  my @filtered_chunks = ();
  my %filtered_hash = ();
  my %real_index_to_filtered_index = ();
  my %filtered_index_to_real_index = ();

  my @all_chunks = @{$self->{all_chunks}};
  my $filtered_chunk_count = 0;

  for (my $i = 0; $i < scalar(@all_chunks); $i++) {
    my $chunk = $self->{all_chunks}[$i];
    my $text = $chunk->text;
    if (!($options->{ignore_blanks} && $text =~ m!^\s*$!)) {
      push @filtered_chunks, $chunk;
      $real_index_to_filtered_index{$i} = $filtered_chunk_count;
      $filtered_index_to_real_index{$filtered_chunk_count} = $i;
      push @{$filtered_hash{hash($options, $text)}}, $chunk;
      $filtered_chunk_count++;
    }
  }

  return \@filtered_chunks, \%filtered_hash,
         \%real_index_to_filtered_index, \%filtered_index_to_real_index;
}

sub _get_map_key_from_options
{
  my $self = shift;
  my $options = shift;
  return
    ("key_" .
     ($options->{ignore_case} ? "w" : "W") . "_" .
     ($options->{ignore_blanks} ? "b" : "B") . "_" .
     ($options->{ignore_case} ? "i" : "I"));
}

sub _maybe_make_filtered_maps
{
  my $self = shift;
  my $options = shift;

  my $key = $self->_get_map_key_from_options($options);

  if (!exists $self->{filtered_chunks}{$key}) {
    ($self->{filtered_chunks}{$key},
     $self->{filtered_hash}{$key},
     $self->{real_to_filtered}{$key},
     $self->{filtered_to_real}{$key}) = $self->_make_chunk_maps($options);

  }
}

sub get_filtered_chunks
{
  my $self = shift;
  my $options = shift;

  my $key = $self->_get_map_key_from_options($options);

  $self->_maybe_make_filtered_maps($options);

  return @{$self->{filtered_chunks}{$key}};
}

sub get_matching_chunks
{
  my $self = shift;
  my $options = shift;
  my $text = shift;

  my $key = $self->_get_map_key_from_options($options);

  $self->_maybe_make_filtered_maps($options);

  my $chunk_hash = $self->{filtered_hash}{$key};

  return @{$chunk_hash->{hash($options, $text)} || []};
}

sub get_filtered_indx_from_real
{
  my $self = shift;
  my $options = shift;
  my $real_indx = shift;

  my $key = $self->_get_map_key_from_options($options);

  $self->_maybe_make_filtered_maps($options);

  return $self->{real_to_filtered}{$key}{$real_indx};
}

sub get_real_indx_from_filtered
{
  my $self = shift;
  my $options = shift;
  my $filtered_indx = shift;

  my $key = $self->_get_map_key_from_options($options);

  $self->_maybe_make_filtered_maps($options);

  return $self->{real_to_filtered}{$key}{$filtered_indx};
}

sub get_previous_chunk
{
  my $self = shift;
  my $chunk = shift;
  my $options = shift;

  my $filtered_indx =
    $self->get_filtered_indx_from_real($options, $chunk->get_indx);
  return $self->get_filtered_chunks($options)->[$filtered_indx];
}

1;
