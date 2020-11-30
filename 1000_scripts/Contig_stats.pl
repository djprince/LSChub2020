#!/usr/bin/perl

	$file = $ARGV[0];

open(FILE, "<$file")
        or die;

while (<FILE>) {
	$id = $_;
	$seq= <FILE>;
	chomp ($seq);
	
	$len = length($seq);

	print "$len\n"; 

}
close FILE;

