#!/usr/bin/perl
use warnings;
use strict;
use v5.10;
use Music::SetTheory;

my $set = Music::SetTheory->newSet(-3, 0, 4);


say "Set: ", $set->printSet();

my @inverted = $set->invert(150);
print "Inverted: @inverted\n";
say "Transposed (4): ", map {"$_ "} $set->transpose(4);
$set->printSetData();



say "Normal form: ", $set->printNormal();
say "Prime form: ", $set->printPrime();
say "Forte number: ", $set->printForte();
say "Interval vector: ", $set->printIntervalVector();



my @row = qw(2 1 9 t 5 3 4 0 8 7 6 e);
my $row = Music::SetTheory->newRow(@row);

say "I4: ", $row->printRow("I4");
#say "Calculated:";
#my @matrix = $row->getMatrix();
#say "@$_" for (@matrix);

$row->printMatrix(4);
