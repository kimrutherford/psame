package Text::Same::ChunkedSource;

use warnings;
use strict;
use Carp;

#use String::CRC32;

sub new
{
  my $arg  = shift;
  my $class = ref($arg) || $arg;

  my $self = {};

  my %params = @_;

  $self->{chunks} = _make_chunks(@{$params{lines}});
  $self->{hash} = _get_chunk_hash(@{$params{lines}});

  return bless $self, $class;
}

sub _make_chunks
{
  my @chunks_text = @_;

#  print STDERR "_make_chunks text: @chunks_text\n";

  my @ret = ();

  for (my $i = 0; $i < scalar(@chunks_text); ++$i) {
    push @ret, new Text::Same::Chunk(text=>$chunks_text[$i], indx=>$i);
  }

#  print STDERR "_make_chunks: @ret\n";

  return \@ret;
}

sub _get_chunk_hash
{
  my %ret_hash = ();

  for (my $i = 0; $i < @_; ++$i) {
    my $chunk_text = $_[$i];
    push @{$ret_hash{$chunk_text}}, new Text::Same::Chunk(text=>$chunk_text, indx=>$i);
  }

  return \%ret_hash;
}

sub get_all_chunks
{
  my $self = shift;
  return @{$self->{chunks}};
}

sub get_chunk_hash
{
  my $self = shift;
  return %{$self->{hash}};
}

1;
