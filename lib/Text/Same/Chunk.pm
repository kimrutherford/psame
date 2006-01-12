package Text::Same::Chunk;

=head1 NAME

Text::Same::Chunk - a chunk of a text for matching

=head1 SYNOPSIS

  my $chunk = new Text::Same::Chunk(text=>$some_text, indx=>$line_number);

=head1 DESCRIPTION

Objects of this class hold information about a chunk of text, generally a
line/sentence/paragraph.

=head1 METHODS

See below.

=head1 AUTHOR

Kim Rutherford <kmr+same@xenu.org.uk>

=head1 COPYRIGHT

Copyright (C) 2005, 2006 Kim Rutherford. All Rights Reserved.

=head1 DISCLAIMER

This module is provided "as is" without warranty of any kind. It
may redistributed under the same conditions as Perl itself.

=cut

use warnings;
use strict;
use Carp;

=head2 new

 Title   : new
 Usage   : $chunk = new Text::Same::Chunk(text=>$some_text,
                                          indx=>$line_number);
 Function: Create a new object to hold information about a chunk of text,
           generally a line/sentence/paragraph.
 Returns : An Text::Same::Chunk object

=cut

sub new
{
  my $self  = shift;
  my $class = ref($self) || $self;
  my %params = @_;

  for my $param_name (keys %params) {
    if (!grep /^$param_name$/, ("text", "indx")) {
      croak "illegal arg in Chunk constructor:\n" .
            "$param_name=>$params{$param_name}\n"
    }
  }

  return bless {%params}, $class;
}

=head2 text

 Title   : text
 Usage   : $chunk->text;
 Function: return the text that was passed to new()

=cut

sub text
{
  my $self = shift;
  return $self->{text};
}

=head2 indx

 Title   : indx
 Usage   : $chunk->indx;
 Function: return the indx that was passed to new()

=cut

sub indx
{
  my $self = shift;
  return $self->{indx};
}

1;
