package Text::Same::Chunk;

use warnings;
use strict;
use Carp;
use String::CRC32;

sub new
{
  my $self  = shift;
  my $class = ref($self) || $self;
  my %params = @_;

  for my $param_name (keys %params) {
    if (!grep /^$param_name$/, ("text", "indx")) {
      croak "illegal arg in Chunk constructor: $param_name=>$params{$param_name}\n"
    }
  }

  return bless {%params}, $class;
}

sub text
{
  my $self = shift;
  return $self->{text};
}

sub indx
{
  my $self = shift;
  return $self->{indx};
}

sub hash
{
  return crc32(shift->text());
}

1;
