use warnings;
use strict;

use Test::More tests => 20;
use Music::SetTheory;

my $croakMsg = qr/only contain numbers/;

# check things that shouldn't die
unlike(newWithThis(0, 1, 4,), $croakMsg, 'standard list');
unlike(newWithThis(qw/0 1 4/), $croakMsg, 'qw list');
unlike(newWithThis(0, 1, '4'), $croakMsg, 'string num in construct');
unlike(newWithThis(qw/0 t 4/), $croakMsg, 't in construct');
unlike(newWithThis(qw/0 T 4/), $croakMsg, 'T in construct');
unlike(newWithThis(qw/0 e 4/), $croakMsg, 'e in construct');
unlike(newWithThis(qw/0 E 4/), $croakMsg, 'E in construct');
unlike(newWithThis(qw/0 a 4/), $croakMsg, 'a in construct');
unlike(newWithThis(qw/0 A 4/), $croakMsg, 'A in construct');
unlike(newWithThis(qw/0 b 4/), $croakMsg, 'b in construct');
unlike(newWithThis(qw/0 B 4/), $croakMsg, 'B in construct');
unlike(newWithThis(qw/0 -1 -4/), $croakMsg, 'small negative numbers');
unlike(newWithThis(qw/0 14 12734/), $croakMsg, 'big numbers in construct');
unlike(newWithThis(qw/0 -14 -12734/), $croakMsg, 'big negative numbers in construct');
unlike(newWithThis(qw/0 0 0 0/), $croakMsg, 'all zeros');

# check things that should die
like(newWithThis(0, 1, 'c'), $croakMsg, 'bad letter in construct');
like(newWithThis(qw/0 1 c/), $croakMsg, 'bad letter in qw construct');
like(newWithThis(0, 1, 'ten'), $croakMsg, 'ten in list construct');
like(newWithThis(qw/0 1 ten/), $croakMsg, 'ten in construct');
like(newWithThis(qw/0 1 eleven/), $croakMsg, 'eleven in construct');

sub newWithThis {
    my $res = eval { my $set = Music::SetTheory->newSet(@_); };
    return $@ || "didn't die";
}

