#!/usr/bin/perl
#
# Print all repos of the APPLICATION as set in AMADEUS_XML

use Local::AmadeusXML;
use Data::Dumper;

my $APPLICATION = $ARGV[0];

(my $appl = $APPLICATION) =~ s/-.*$//;

my $os;
if( $APPLICATION =~ '-' ) {
    ($os = $APPLICATION) =~ s/^.*-//;
}

$os = $os ? $os : 'UNIX';

use constant {
    AMADEUS_XML  => '/vobstore/disk9/releases_info/Amadeus.xml',
};

my $amadeus_extract   = Local::AmadeusXML->parse( AMADEUS_XML );
my $application = $amadeus_extract->lookup_application( $appl, $os );
my @repos = $application->repos;

for my $repo( @repos ) {
    $repo =~ s/.*\///;
    print($repo);
}
