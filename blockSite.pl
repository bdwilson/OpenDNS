#!/usr/bin/perl
#
use LWP::UserAgent;
use HTTP::Request;
use POSIX qw(strftime);
use Getopt::Long;
use JSON;

### Helpful URL's if you wish to extend this.
# https://docs.umbrella.com/developer/enforcement-api/
# https://support.umbrella.com/hc/en-us/articles/231248748
# https://docs.umbrella.com/developer/enforcement-api/generic-event-format-field-descriptions2/

### Edit below here
$deviceid="abcde­12345-abcde-12345-abcde"; # Just make something up here.
$version="1.0";

# Name is whatever you want to call it, customer key is what you get from your
# Umbrella account under Settings -> Integrations. Create a new Integration,
# call it whatever you wish, then get the key and put here. If you have
# multiple orgs in your Umbrella account, you'll have to do this to each and
# list them all here. 
%orgs=("org1" => "1212-1212-1212-1212-1212-12121212",
       "org2" => "2323−2323-2323-2323-2323-23232323");

### Stop edits
GetOptions(
    'add=s' => \$domain_add,
    'remove=s' => \$domain_remove,
    'list' => \$domain_list,
) or die "Usage: $0 [--add domain | --remove domain | --list]\n";

if (!$domain_add && !$domain_remove && !$domain_list) {
	print "Usage: $0 [--add domain | --remove domain | --list]\n";
	exit;
}

my $now_string = strftime "%Y-%m-%dT%H:%M:%S.0Z", gmtime;

if ($domain_add) { 
   $url="https://s-platform.api.opendns.com/1.0/events?customerKey=";
   my $json = "{\"deviceId\": \"$deviceid\", \"deviceVersion\": \"$version\", \"dstDomain\": \"$domain_add\", \"dstUrl\": \"http://$domain_add\", \"protocolVersion\": \"1.0a\", \"providerName\": \"Security Platform\", \"alertTime\": \"$now_string\", \"eventTime\": \"$now_string\"}";

   foreach $org (keys %orgs) {
	$orgURL=$url . $orgs{$org};
	my $req = HTTP::Request->new(POST => $orgURL);
	$req->content_type('application/json');
	$req->content($json);;
	my $ua = LWP::UserAgent->new; # You might want some options here
	my $response = $ua->request($req);
	if ( $response->is_success() ) {
		print "Successfully added block for $domain_add to $org\n";
	} else {
		print "Error:" . $response->status_line() . "\n";
	}
 }
 exit;
} 

if ($domain_remove) {
   $url="https://s-platform.api.opendns.com/1.0/domains?customerKey=";
   foreach $org (keys %orgs) {
	$orgURL=$url . $orgs{$org} . "&where[name]=" . $domain_remove;
	my $req = HTTP::Request->new(DELETE => $orgURL);
	$req->content_type('application/json');
	my $ua = LWP::UserAgent->new; # You might want some options here
	my $response = $ua->request($req);
	if ( $response->is_success() ) {
		print "Successfully removed block for $domain_remove from $org\n";
	} else {
		print "Error:" . $response->status_line() . "\n";
	}
   }
   exit;
}

if ($domain_list) {
   $url="https://s-platform.api.opendns.com/1.0/domains?customerKey=";
   foreach $org (keys %orgs) {
	$page = 1;
	$pages= 1;
	while($pages) {
		$orgURL=$url . $orgs{$org} . "&page=$page&limit=200";
		my $req = HTTP::Request->new(GET=> $orgURL);
		$req->content_type('application/json');
		my $ua = LWP::UserAgent->new; # You might want some options here
		my $response = $ua->request($req);
		if ($response->is_success() ) {
			#print Dumper $response;
			my $json = JSON->new;
			my $decoded_json = from_json( $response->content, { utf8  => 1 } );
			#print Dumper $decoded_json->{"meta"};
			if ($decoded_json->{'meta'}->{'next'} =~ /page=(\d+)/) {
				$page=$1;
			} else {
				$pages=0;
			}
			foreach(@{$decoded_json->{"data"}}) {
				print "$org -> " . $_->{"name"} . "\n";
			}
		} else {
			print "Error:" . $response->status_line() . "\n";
		}
	}
   }
}
