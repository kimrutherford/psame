package Text::Same::Cache;

use warnings;
use strict;
use Carp;

use Text::Same::ChunkedSource;

sub new
{
  my $self  = shift;
  my $class = ref($self) || $self;
  return bless {}, $class;
}

sub get
{
  my $self = shift;

  my $filename = shift;
  my @lines = ();

  local $/ = "\n";
  if ($filename =~ /(rcs|svn|co).*\|/) {
    open F, "$filename" or carp "$!: $filename";

    @lines = map {chomp; $_} (<F>);
  } else {
#     eval q{require Tie::File; tie @lines, 'Tie::File', $filename};

#     if ($@) {
#       warn "Tie::File is not available - emulating (error was $@)\n";
      open F, "<$filename" or carp "$!: $filename"; 
      @lines = map {chomp; $_} (<F>);
#    }
  }
  return new Text::Same::ChunkedSource(name=>$filename, chunks=>\@lines);
}

=head1 AUTHOR

Kim Rutherford, C<< <kmr at xenu.org.uk> >>

=head1 COPYRIGHT & LICENSE

Copyright 2005,2006 Kim Rutherford, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
