#!/usr/bin/perl

use Domain::PublicSuffix;

# location to keep track of unique root domains you've processed. You might not
# want to keep this in /tmp if you want to persist across reboots/runs. 
my $processed_domains = "/tmp/sent_to_opendns.dat";
# configured script used to add new OpenDNS blocks.
my $opendns_blockSite = "/usr/local/bin/blockSite.pl";

my $suffix = Domain::PublicSuffix->new({
   'data_file' => '/tmp/effective_tld_names.dat'
});
open(PROC, "<$processed_domains");
while(<PROC>) {
	chomp;
	$domains{$_}++;
}
close(PROC);

while(<>) {
	chomp;
	$my_domain=$_;
	$root = $suffix->get_root_domain($my_domain);
	if (!$domains{$root}) {
		# add to opendns
		print "$my_domain\n";
		open(ODNS, "$opendns_blockSite --add $root|");
		while(<ODNS>) {
			print;
		}
		close(ODNS);
		$domains{$root}++;
	}
}
open(PROC, ">$processed_domains");
foreach $domain (sort keys %domains) {
	print PROC $domain . "\n";;
}
close(PROC);
	


