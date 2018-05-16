#!/usr/bin/perl
#
# Print all applicatiosn of the REPO as set in AMADEUS_XML

use Local::AmadeusXML;

my $REPO = $ARGV[0];

use constant {
    AMADEUS_XML  => '/vobstore/disk9/releases_info/Amadeus.xml',
};

my $amadeus_extract   = Local::AmadeusXML->parse( AMADEUS_XML );
my @applications = @{$amadeus_extract->applications()};

for my $app (@applications){
    my $appname = $app->{name};
    my $os  = $app->{env};
    my $repo = $app->{repos}[0];

    if( $repo =~ /$REPO/ ) {
        print "$appname-$os\n";
    }
}
