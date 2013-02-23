use warnings;
use strict;

use Test::More tests => 21;
use Music::SetTheory;

my $set = Music::SetTheory->newSet(qw/0 1 4/);
isa_ok($set, 'Music::SetTheory');

can_ok($set, $_) for qw/normal prime intervalVector/;
can_ok($set, $_) for qw/printSet printNormal printPrime printIntervalVector
                        printForte printSetData/;
can_ok($set, $_) for qw/transpose invert/;

my $row = Music::SetTheory->newRow(qw/0 1 2 3 4 5 6 7 8 9 t e/);
isa_ok($row, 'Music::SetTheory');
can_ok($row, $_) for qw/getP getI getR getRI printRow printMatrix/;
can_ok($row, $_) for qw/transpose invert/;
