#!perl -T

use Test::More tests => 3;

use Text::Same;

my @t1 = qw{b c};
my @t2 = qw{b c b c};

my @matches = same \@t1, \@t2;

ok(scalar(@matches) == 2);

my @sorted_matches = sort {
  my $min1_cmp = $a->{min1} <=> $b->{min1}; 
  if ($min1_cmp == 0) {
    $a->{min2} <=> $b->{min2};
  } else {
    $min1_cmp;
  }
} @matches;

my $match1 = $sorted_matches[0];
my $match2 = $sorted_matches[1];

ok($match1->score() == 4);
ok($match2->score() == 4);
