#!/usr/bin/perl

$samples = $ARGV[0];
$genos = $ARGV[1];
$subset=1000; #set to 0 to include all loci

#if ($#ARGV != 1 ) { print "oops! Input error 1\n"; die;}
open(FILE, "< $samples") or die;
for ($samp_wc=0; <FILE>; $samp_wc++) {$samp = $_; chomp $samp; $samps[$samp_wc]= $samp;}
close(FILE);
open(FILE, "< $genos") or die;
for ($geno_wc=0; <FILE>; $geno_wc++) {@tabs = split(/\t/, $_); $loci[$geno_wc] = "$tabs[0]_$tabs[1]";}
close(FILE);

if ($subset > 0) {
	#print "choosing $subset random loci from $geno_wc total loci...\n";
	@choose = ();
	while (scalar(@choose) < $subset && scalar(@choose) < $geno_wc) {
		$rand_num = int(rand(($geno_wc+1)));
		if ($rand_num>0) {
			push(@choose, $rand_num) unless grep{$_ == $rand_num} @choose;
		}
	}	
	@chosen = sort { $a <=> $b } @choose;
}
else {@chosen = (1..($geno_wc +1))};
#print "@chosen\n";

$y=2; ##two here accounts for the chr'\t'bp columns
while ($y < $samp_wc + 2 ) {
	$samp = $samps[$y-2]; chomp($samp);
	print ">$samp\n";
	open (FILE, "< $genos") or die;
	$x=1;
	while (<FILE>) {
		if (grep $_ == $x, @chosen){
			$line = $_; chomp($line);
			@tabs = split(/\t/,$line);
			$geno = $tabs[$y];
			($a1,$a2) = split(//,$geno);
			$a3="";
			
			if ($a1 eq $a2 ) {$a3 = $a1;}
			elsif($geno eq "AT" || $geno eq "TA") {$a3 = "W";}
			elsif($geno eq "AC" || $geno eq "CA") {$a3 = "M";}
			elsif($geno eq "AG" || $geno eq "GA") {$a3 = "R";}
			elsif($geno eq "CT" || $geno eq "TC") {$a3 = "Y";}
			elsif($geno eq "GT" || $geno eq "TG") {$a3 = "K";}
			elsif($geno eq "GC" || $geno eq "CG") {$a3 = "S";}
			else{print "oops! Logic error 1\n"; die;}
			print $a3;
		}
		$x++;
	}
	print "\n";	
	$y++;
}
