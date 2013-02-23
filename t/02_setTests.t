use warnings;
use strict;

use Test::More 'no_plan';
use Music::SetTheory;

my $set = Music::SetTheory->newSet(qw/3 0 4/);
ok(&checkNormal($set), 'normal form');
ok(&checkPrime($set), 'prime form');

sub checkNormal {
    my $set = shift;
    my @normal = $set->normal();
    my @expected = (0, 3, 4);
    for (0..$#normal) {
        return 0 unless $normal[$_] == $expected[$_];
    }
    return 1;
}

sub checkPrime {
    my $set = shift;
    my @prime = $set->prime();
    my @expected = (0, 1, 4);
    for (0..$#prime) {
        return 0 unless $prime[$_] == $expected[$_];
    }
    return 1;
}
