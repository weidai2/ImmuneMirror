#!/usr/bin/perl
use warnings;
use strict;

my $filename = $ARGV[0];
my @hla; 
open(FH, '<', $filename) or die $!;
@hla=<FH>;
close(FH);

my $out_hla;
my $tmp;
my $tmp2;
my $tmp1;
foreach my $line (@hla) {
my @out=split(/\t/, $line);
if($out[2] !~ m/Allele/i){
	#if($out[1] =~ /^[ABC]/){
	#$tmp1=substr($out[1],0,7);
	#$tmp=substr($out[2],0,7);
	#if ($tmp eq $tmp1){
	#$tmp2="HLA-$tmp1";
	#}
	#else{
	#$tmp2="HLA-$tmp1,HLA-$tmp";
	#}
	#	print "$tmp2\n";
	#}
	if($out[1] =~ /^[D]/){
	$tmp1=substr($out[1],0,10);
	$tmp=substr($out[2],0,10);
	if($tmp eq $tmp1){
	$tmp2=$tmp1;
	}
	else{
	$tmp2="$tmp1,$tmp";
	}
					 
	if($out[1] =~ /^DQA/){
		$out_hla= "$tmp2";
	}	
	if($out[1] !~ /^DQA/){
		$out_hla="$out_hla,$tmp2"
	}
	}
}
  }
print "$out_hla\n";

#sub uniq {
#	    my %seen;
#	        grep !$seen{$_}++, @_;
#	}sub uniq {
#		    my %seen;
#		        grep !$seen{$_}++, @_;
#		}
