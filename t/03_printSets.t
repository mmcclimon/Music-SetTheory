use warnings;
use strict;

use Music::SetTheory;
use Test::More;

my $set = Music::SetTheory->newSet(4, 1, 5);
is($set->printSet(), '{4, 1, 5}', 'printSet');
is($set->printNormal(), '{1, 4, 5}', 'printNormal');
is($set->printPrime(), '(014)', 'printPrime');
is($set->printForte(), '3-3');
is($set->printIntervalVector(), '<101100>');


done_testing(5);
