#!/usr/bin/perl
#
# Print Live cycles to STDOUT.
# Parsed from AMADEUS_XML.

use Local::AmadeusXML;

use constant {
    AMADEUS_XML  => '/vobstore/disk9/releases_info/Amadeus.xml',
};

my $amadeus_extract   = Local::AmadeusXML->parse( AMADEUS_XML );

my @active_cycles_all = grep { $_->active } $amadeus_extract->cycles_all;
my @active_cycles     = map  { $_->name   } @active_cycles_all;

for my $live_cycle( @active_cycles ) {
    print "$live_cycle\n";
}
