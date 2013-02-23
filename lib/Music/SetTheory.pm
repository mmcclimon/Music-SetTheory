package Music::SetTheory;

use 5.012003;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Music::SetTheory ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw( newSet newRow normal prime intervalVector printSet printNormal printPrime  printForte printIntervalVector printSetData transpose invert getP getI getR getRI printRow printMatrix ) ],
 	'sets' => [qw(newSet normal prime intervalVector printSet printNormal printPrime  printForte printIntervalVector printSetData transpose invert)],
	'rows' => [qw(newRow transpose invert getP getI getR getRI printRow printMatrix )]);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw( );

our $VERSION = '0.01';

=head1 NAME

Music::SetTheory - Perl extension for post-tonal tools (pitch-class set theory and 12-tone row manipulation)

=head1 SYNOPSIS

  use Music::SetTheory;
  $set = Music::SetTheory->newSet(2, 6, 9);
  $row = Music::SetTheory->newRow(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11);
  
data for set, all return arrays

  @normal = $set->normal();
  @prime  = $set->prime();
  @vector = $set->intervalVector();

print-friendly set data, all return strings

  print $set->printSet();
  print $set->printNormal();
  print $set->printPrime();
  print $set->printIntervalVector();
  print $set->printForte();
  
  print $set->printData();

transformations, take index as parameter, return array

  @transposed = $set->transpose($index);
  @inverted   = $set->invert($index);


row operations

 
  my @pForm  = $row->getP($index);
  my @iForm  = $row->getI($index);
  my @rForm  = $row->getR($index);
  my @riForm = $row->getRI($index);


  print $row->printRow('P4');
  $row->printMatrix();

=head1 DESCRIPTION

This object-oriented module provides tools for post-tonal music 
analysis. Included are methods to find the normal form, prime form,
interval vector, and Forte number of a given set, as well as methods
for transposing and inverting sets. Row tools include methods to get
P, I, R, and RI forms of a row, as well as to print a matrix with
all 48 forms.

=head2 EXPORT

=over

=item C<:all>

  newSet, normal, invert, transpose, prime, printSet, 
  printPrime, printNormal, printForte, intervalVector, 
  printIntervalVector, printSetData, newRow, getP, getI, getR, getRI, 
  printRow, printMatrix

=item C<:sets>

  newSet, normal, prime, intervalVector, printSet, 
  printNormal, printPrime  printForte printIntervalVector,
  printSetData transpose invert

=item C<:rows>

  newRow, transpose, invert, getP, getI, getR, getRI, 
  printRow, printMatrix

=back

=head1 FUNCTIONS

=cut

# Preloaded methods go here.

use Carp;

=head2 Constructor functions

=over

=item newSet

  $set = Music::SetTheory->newSet(2, 6, 9);

Constructs an instance of the class, and takes a list as a 
parameter. Duplicate pcs are removed, but the order is maintained. 
"t" and "e" or "a" and "b" may be used for pcs 10 and 11, but be sure
to quote them in a list. All of the following end up the same when
passed to C<newSet> :

  @set = qw(2 4 t e);
  @set = (2, 4, 10, 11);
  @set = qw( 2 4 a b);

=cut

sub newSet {
	my $class = shift;
	my @set = @_;
	@set = validate(\@set);
	bless \@set, $class;
}

=item newRow

  $row = Music::SetTheory->newSet(qw(0 1 2 3 4 5 6 7 8 9 t e));

Constructs an instance of the class, and takes a list as a 
parameter. A row must have exactly 12 unique pitch classes. 
"t" and "e" or "a" and "b" may be used for pcs 10 and 11, but be sure
to quote them in a list. All of the following end up the same when
passed to C<newRow> :

  @row = qw(0 1 2 3 4 5 6 7 8 9 t e);
  @row = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11);
  @row = qw(0 1 2 3 4 5 6 7 8 9 a b);

=back

=cut

sub newRow {
	my $class = shift;
	my @row = @_;
	
	unless (@row == 12) {croak "Row must have exactly 12 elements"; }
	@row = validate(\@row);

	my %seen = ();
	for(@row) {
		if ($seen{$_}++) { croak "Row must have exactly 12 unique elements (check for duplicates)" }
	}
	bless \@row, $class;
}

# helper function, validates 
sub validate {
	my $subj = shift;	
	my %seen = ();
	my @validated;

	for (@$subj) {
		if (/^-?\d+$/) { $_ %= 12;}
		elsif (/^t$|^a$/i) {$_ = 10;}
		elsif (/^e$|^b$/i) {$_ = 11;}
		else {croak "Error: set can only contain numbers and 't/e' or 'a/b' for pcs 10/11";}
		next if $seen{$_}++;
		push @validated, $_;
	}
	return @validated;
}

=head2 Instance methods

=over

=item normal

  @normal = $set->normal();

Returns a list of the set's normal form

=cut

sub normal {
	ref (my $set = shift) or croak "Instance variable needed";
	my @candidates;
	
	#fill @candidates with rotations of set (instance)
	my @sorted = sort { $a <=> $b } @$set;
	for (0..$#sorted) {
		my @tmp = @sorted;
		$candidates[$_] = \@tmp;
		$a = shift @sorted;
		push @sorted, $a;
	}
	undef @sorted;
	
	# check value at top of loop, if no normal order, calculates differences and tries again
	my $check = @candidates - 1;
	my $smallest = 50; #set to arbitrary high number
	while (1) {
		my (@keep, $diff);
		
		#run loop to get diffs, store arrays with smallest diffs in @keep
		for (my $index = 0; $index < @candidates; $index++) {
			my @tmp = @{$candidates[$index]};
			$diff = ($tmp[$check] - $tmp[0]) % 12;
			if ($diff < $smallest) {
				$smallest = $diff;
				@keep = ();
				push @keep, \@tmp;
			} elsif ($diff == $smallest) {
				push @keep, \@tmp;
			}
		}
		
		#remove failed candidates, empty keep array and decrement to prepare next loop
		@candidates = @keep;
		@keep = ();
		$check--;

		# loop exits on finding normal form, retries if normal form not found yet
			# if only one candidate left, that's normal form
			# if more than one candidate is equally good, smallest first number wins
		return @{$candidates[0]} if (@candidates == 1 || $check == 0);

	}
}

=item prime

  @prime = $set->prime();

Returns a list of the set's prime form

=cut

# calls &normal and &invert;
sub prime {
	ref (my $set = shift) or croak "Instance variable needed";
	
	my @norm = &normal($set);
	my @inv = &invert($set);
	@inv = &normal(\@inv);
	
	# set arrays to begin at 0
	@norm = map { ($_ - $norm[0]) %12 } @norm;
	@inv = map { ($_ - $inv[0]) %12 } @inv;
	
	#figure out lowest prime form
	my ($nComp, $iComp) = "";
	$nComp .= "$_ " for(@norm);
	$iComp .= "$_ " for(@inv);
	my $prime = $nComp cmp $iComp;
	
	#return proper array
	$prime == 1 ? return @inv : return @norm;
}

=item intervalVector

  @vector = $set->intervalVector();

Returns a list of the set's interval vector

=cut

sub intervalVector {
	ref (my $set = shift) or croak "Instance variable needed";
	my @normal = &normal($set);	
	my @vector = (0, 0, 0, 0, 0, 0);
	my $check = 0;

	while ($check < @normal-1) {
		for (my $i = $check + 1; $i < @normal; $i++) {
			my $int = ($normal[$i] - $normal[$check]) % 12;
			if ($int == 11) {$int = 1 }
			elsif ($int == 10) {$int = 2 }
			elsif ($int == 9) {$int = 3 }
			elsif ($int == 8) {$int = 4 }
			elsif ($int == 7) {$int = 5 }
			my $index = $int - 1;
			$vector[$index]++;
		}
	$check++;
	}	
	return @vector;
	
	
}


=item printSet

  print $set->printSet();

Returns a string of a set, in the form '{x, y, z}'

=cut

sub printSet {
	ref (my $set = shift) or croak "Instance variable needed";
	my $lastIndex = @$set-1;
	
	my $setF = "{";
	$setF .= "$set->[$_], " for(0..$lastIndex-1);
	$setF .= "$set->[-1]}";
	return $setF;
}

=item printNormal

  print $set->printNormal();

Returns a string of the set's normal form, in the form '{x, y, z}'

=cut


sub printNormal {
	ref (my $set = shift) or croak "Instance variable needed";
	printSet( [normal($set)] );
}

=item printPrime

  print $set->printPrime();

Returns a string of the set's prime form, in the form '(xyz)',
using 't' and 'e' for pcs 10 and 11.

=cut

sub printPrime {
	ref (my $set = shift) or croak "Instance variable needed";
	my $primeF = "(";
	
	for (prime($set)) {
		if ($_ == 10) {$primeF .= "t";}
		elsif ($_ == 11) {$primeF .= "e";}
		else {$primeF .= "$_";}
	}
	$primeF .= ")";
	return $primeF;
}

=item printForte

  print $set->printForte();

Returns a string of the set's Forte Number, in the form "4-Z15"

=cut

sub printForte {
	ref (my $set = shift) or croak "Instance variable needed";
	my $prime = "";
	# hash of Forte numbers, keys = prime form, values = Forte number
	my %fortes = qw ( 
		0 1-1

		01 2-1 02 2-2 03 2-3 04 2-4 05 2-5 06 2-6

		012 3-1 013 3-2 014 3-3 015 3-4 016 3-5 024 3-6 025 3-7 026 3-8 027 3-9 036 3-10 037 3-11 048 3-12

		0123 4-1   0124 4-2  0125 4-4  0126 4-5  0127 4-6  0134 4-3  0135 4-11 0136 4-13 0137 4-Z29 0145 4-7 
		0146 4-Z15 0147 4-18 0148 4-19 0156 4-8  0157 4-16 0158 4-20 0167 4-9  0235 4-10 0236 4-12  0237 4-14 
		0246 4-21  0247 4-22 0248 4-24 0257 4-23 0258 4-27 0268 4-25 0347 4-17 0358 4-26 0369 4-28
		
		01234 5-1  01235 5-2   01236 5-4  01237 5-5  01245 5-3   01246 5-9  01247 5-Z36 01248 5-13  01256 5-6 
		01257 5-14 01258 5-Z38 01267 5-7  01268 5-15 01346 5-10  01347 5-16 01348 5-Z17 01356 5-Z12 01357 5-24 
		01358 5-27 01367 5-19  01368 5-29 01369 5-31 01457 5-Z18 01458 5-21 01468 5-30  01467 5-32  01478 5-22 
		01568 5-20 02346 5-8   02347 5-11 02357 5-23 02358 5-25  02368 5-28 02458 5-26  02468 5-33  02469 5-34 
		02479 5-35 03458 5-Z37
		
		012345 6-1   012346 6-2   012347 6-Z36 012356 6-Z3  012348 6-Z37 012456 6-Z4  012357 6-9   012358 6-Z40 
		012457 6-Z11 012367 6-5   012368 6-Z41 012467 6-Z12 012369 6-Z42 013467 6-Z13 012378 6-Z38 012567 6-Z6 
		012458 6-15  012468 6-22  012469 6-Z46 013468 6-Z24 012478 6-Z17 012568 6-Z43 012479 6-Z47 013568 6-Z25 
		012569 6-Z44 013478 6-Z19 012578 6-18  012579 6-Z48 013578 6-Z26 012678 6-7   013457 6-Z10 023458 6-Z39 
		013458 6-15  013469 6-27  013479 6-Z49 013569 6-Z28 013579 6-34  013679 6-30  023679 6-Z29 014679 6-Z50 
		014568 6-16  014579 6-31  014589 6-20  023457 6-8   023468 6-21  023469 6-Z45 023568 6-Z23 023579 6-33 
		024579 6-32  02468t 6-35

		0123456 7-1  0123457 7-2   0123467 7-4  0123567 7-5  0123458 7-3   0123468 7-9  0123568 7-Z36 0124568 7-13  0123478 7-6 
		0123578 7-14 0124578 7-Z38 0123678 7-7  0124678 7-15 0123469 7-10  0123569 7-16 0124569 7-Z17 0123479 7-Z12 0123579 7-24 
		0124579 7-27 0123679 7-19  0124679 7-29 0134679 7-31 0145679 7-Z18 0124589 7-21 0124689 7-30  0134689 7-32  0125689 7-22 
		0125679 7-20 0234568 7-8   0134568 7-11 0234579 7-23 0234679 7-25  0135679 7-28 0134579 7-26  012468t 7-33  013468t 7-34 
		013568t 7-35 0134578 7-Z37
		
		01234567 8-1   01234568 8-2  01234578 8-4  01234678 8-5  01235678 8-6  01234569 8-3  01234579 8-11 01234679 8-13 01235679 8-Z29 01234589 8-7 
		01234689 8-Z15 01235689 8-18 01245689 8-19 01234789 8-8  01235789 8-16 01245789 8-20 01236789 8-9  02345679 8-10 01345679 8-12  01245679 8-14 
		0123468t 8-21  0123568t 8-22 0124568t 8-24 0123578t 8-23 0124578t 8-27 0124678t 8-25 01345689 8-17 0134578t 8-26 0134679t 8-28
		
		012345678 9-1 012345679 9-2 012345689 9-3 012345789 9-4 012346789 9-5 01234568t 9-6 01234578t 9-7 01234678t 9-8 01235678t 9-9 01234679t 9-10 01235679t 9-11 01245689t 9-12
		
		0123456789 10-1 012345678t 10-2 012345679t 10-3 012345689t 10-4 012345789t 10-5 012346789t 10-6
		
		0123456789t 11-1
		
		0123456789te 12-1
		
	);

	for ( prime($set) ) {
		if ($_ == 10) { $_ = "t";}
		elsif ($_ == 11) {$_ = "e";}
		$prime .= $_;
	}

	die "$prime is an invalid prime form; no Forte number exists." unless (exists $fortes{$prime});
	return $fortes{$prime};
}

=item printIntervalVector

  print $set->printIntervalVector();

Returns a string of the set's interval vector, in the 
form '<123456>'

=cut

sub printIntervalVector {
	ref (my $set = shift) or croak "Instance variable needed";
	my $vector ="<";
	$vector .= $_ for ( intervalVector($set) );
	$vector .= ">";
}

=item printSetData

  $set->printSetData();

Prints all data for a set (note: does not return a string!).
Equivalent to the following:

  print "Set:             ", $set->printSet(), 	          "\n";
  print "Normal form:     ", $set->printNormal(),         "\n";
  print "Prime form:      ", $set->printPrime(),          "\n";
  print "Interval vector: ", $set->printIntervalVector(), "\n";
  print "Forte number:    ", $set->printForte(),          "\n";

=cut

sub printSetData {
	ref (my $set = shift) or croak "Instance variable needed";
	print "Set:             ", $set->printSet(), 			"\n";
	print "Normal form:     ", $set->printNormal(),			"\n";
	print "Prime form:      ", $set->printPrime(), 			"\n";
	print "Interval vector: ", $set->printIntervalVector(), "\n";
	print "Forte number:    ", $set->printForte(), 			"\n";
	
}

=item transpose

  @transposed = $set->tranpose($index);

Returns a list of the transposition of the set by the index given
in the parameter. If no parameter is given, assumes T0.

=cut

sub transpose {
	ref (my $set = shift) or croak "Instance variable needed";
	my $index = ($_[0]) ? shift : 0 ;
	croak "Index of transposition must be an integer" unless ($index =~ /^-?\d+$/);
	my @transposed = map {($index + $_) % 12} @$set;
	return @transposed;
	
}

=item invert

  @inverted = $set->invert($index);

Returns a list of the inversion of the set about the index given
in the parameter. If no parameter is given, assumes I0.

=cut

sub invert {
	ref (my $set = shift) or croak "Instance variable needed";
	my $index = ($_[0]) ? shift : 0 ;
	croak "Index of inversion must be a positive integer" unless ($index =~ /^\d+$/);
	my @inverted = map {($index - $_) % 12} @$set;
	return @inverted;
}



=item getP

  @pForm = $row->getP($index);

Returns a list of the P form whose first note is the pitch class
given in the parameter. If no parameter is given, P0 is assumed.

=cut

sub getP {
	ref (my $row = shift) or croak "Instance variable needed";
	my $index = ($_[0]) ? shift : 0 ;	
	croak "Index must be an integer" unless ($index =~ /^\d+$/);
	$index -= $row->[0];
	my @pForm = map { ($_ + $index) %12 } @$row;	
}

=item getI

  @iForm = $row->getI($index);

Returns a list of the I form whose first note is the pitch class
given in the parameter. If no parameter is given, I0 is assumed.
(Note: To get a an I form that is inverted about a pitch class, use
$row->invert($index) instead)

=cut

sub getI {
	ref (my $row = shift) or croak "Instance variable needed";
	my $index = ($_[0]) ? shift : 0 ;	
	croak "Index must be an integer" unless ($index =~ /^\d+$/);
	my @iForm = map { ( 12- $_) %12 } @$row;
	$index -= $iForm[0];
	@iForm = map { ($index + $_) %12 } @iForm;	
}

=item getR

  @rForm = $row->getR($index);

Returns a list of the R form whose last note is the pitch class
given in the parameter. If no parameter is given, R0 is assumed.

=cut

sub getR {
	ref (my $row = shift) or croak "Instance variable needed";
	my $index = ($_[0]) ? shift : 0 ;	
	croak "Index must be an integer" unless ($index =~ /^\d+$/);
	my @rForm = reverse getP($row, $index);
}

=item getRI

  @riForm = $row->getRI($index);

Returns a list of the RI form whose last note is the pitch class
given in the parameter. If no parameter is given, RI0 is assumed.

=cut

sub getRI {
	ref (my $row = shift) or croak "Instance variable needed";
	my $index = ($_[0]) ? shift : 0 ;	
	croak "Index must be an integer" unless ($index =~ /^\d+$/);
	my @riForm = reverse getI($row, $index);
}

=item getMatrix

  @matrix = $row->getMatrix();

Returns a complex array with 12 elements. Each element is an array
reference containing the correct P form of the row. [0] of returned
array is the original row, then ordered according to I forms top-to-
bottom. Useful if the array is going to be processed further (into 
an HTML table, for instance)

=cut

sub getMatrix {
	ref (my $row = shift) or croak "Instance variable needed";
	my @iForm = getI($row, $row->[0]);
	my @matrix;
	for(0..11) {
		push @matrix, [ getP($row, $iForm[$_]) ];
	}
	
	return @matrix;
}

=item printRow

  $rowString = $row->printRow("RI4");

Returns a string of the row in the form "1 2 3 4 5 6 7 8 9 T E 0".
Takes a row form as a parameter; if no parameter given, prints the
row itself.

=cut

sub printRow {
	ref (my $row = shift) or croak "Instance variable needed";
	my $index = shift;	
	my @rowToPrint;
	
	if ($index) {
		if ($index =~ /^(p)(\d+)$/i) { @rowToPrint = getP($row, $2); }
		elsif ($index =~ /^(i)(\d+)$/i) { @rowToPrint = getI($row, $2); }
		elsif ($index =~ /^(r)(\d+)$/i) { @rowToPrint = getR($row, $2); }
		elsif ($index =~ /^(ri|ir)(\d+)$/i) { @rowToPrint = getRI($row, $2); }
		else {croak "Index invalid"; }
	} else { @rowToPrint = @$row}
	
	my $rowP = '';
	for (@rowToPrint) {
		if ($_ == 10) {$rowP .= "T ";}
		elsif ($_ == 11) {$rowP .= "E ";}
		else {$rowP .= "$_ ";}
	}
	return $rowP;
}

=item printMatrix

  $row->printMatrix();

Prints a matrix of all 48 row forms in the traditional manner, with
original row on top (using C=0 notation).

=cut

sub printMatrix {
	ref (my $row = shift) or croak "Instance variable needed";
	my @iForm = getI($row, $row->[0]);
	print $row->printRow("P$_"), "\n" for (@iForm);	
}

=back

=cut

1;
__END__





=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Michael McClimon, E<lt>michael@mcclimon.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Michael McClimon

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.3 or,
at your option, any later version of Perl 5 you may have available.


=cut
