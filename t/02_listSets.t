use warnings;
use strict;

use Test::More 'no_plan';
use Music::SetTheory;

my $set = Music::SetTheory->newSet(qw/4 1 5/);
is(&checkNormal($set), '1 4 5', 'normal form');
is(&checkPrime($set), '0 1 4', 'prime form');
is(&checkVector($set), '1 0 1 1 0 0', 'interval vector');

sub checkNormal {
    my $set = shift;
    my @normal = $set->normal();
    return "@normal";
}

sub checkPrime {
    my $set = shift;
    my @prime = $set->prime();
    return "@prime";
}

sub checkVector {
    my $set = shift;
    my @vec = $set->intervalVector();
    return "@vec";
}
