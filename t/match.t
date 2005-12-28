#!perl -T

use Test::More tests => 8;

use Text::Same;

my @t1 = qw{b c};
my @t2 = qw{b c b c};

my $matchmap = compare \@t1, \@t2;
my @matches = $matchmap->matches;

ok(scalar(@matches) == 2);

my @sorted_matches = sort {
  my $min1_cmp = $a->min1 <=> $b->min1;
  if ($min1_cmp == 0) {
    $a->min2 <=> $b->min2;
  } else {
    $min1_cmp;
  }
} @matches;

my $match1 = $sorted_matches[0];
my $match2 = $sorted_matches[1];

ok($match1->score() == 4);
ok($match2->score() == 4);

my @test_data = (
                 {
                  dir=>"test1",
                  match_count=>2,
                  unmatched1=>0,
                  unmatched2=>0,
                 },
                 {
                  dir=>"test2",
                  match_count=>3,
                  unmatched1=>0,
                  unmatched2=>0,
                 },
                 {
                  dir=>"test3",
                  match_count=>3,
                  unmatched1=>0,
                  unmatched2=>0,
                 },
                 {
                  dir=>"test4",
                  match_count=>9,
                  unmatched1=>0,
                  unmatched2=>3,
                 },
                 {
                  dir=>"test8",
                  match_count=>5,
                  unmatched1=>1,
                  unmatched2=>1,
                 },
                );

for $test_data (@test_data) {
  my $dir = $test_data->{dir};
  my $file1 = "t/data/$dir/file1";
  my $file2 = "t/data/$dir/file2";
  my $matchmap = compare $file1, $file2;

  ok(scalar($matchmap->matches) == $test_data->{match_count});
}
