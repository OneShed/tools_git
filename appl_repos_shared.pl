#!/usr/bin/perl
#
# Print all repos which are shared by multiple applications 

use Local::AmadeusXML;
use Data::Dumper;

use constant {
    AMADEUS_XML  => '/vobstore/disk9/releases_info/Amadeus.xml',
};

my $amadeus_extract   = Local::AmadeusXML->parse( AMADEUS_XML );
my @applications = @{$amadeus_extract->applications()};

# get the hash of $app-os -> $repo
my %app_repo;

for my $app (@applications){
    my $appname = $app->{name};
    my $os  = $app->{env};
    my $repo = $app->{repos}[0];

    my $app_os = "$appname-$os";

    if($repo) {
        $app_repo{"$app_os"} = $repo;
    }
}

# print comma separated keys having the value $val
sub get_keys {
    my( $val ) = @_;

    for my $key( keys %app_repo ) {
        if( $app_repo{$key} eq $val ) {
            print "$key,";
        }
    }
}

# count the values into a hash
my %count;
for (values %app_repo) {
    $count{$_}++;
}

# print all keys if values count >=2
for my $key (sort keys %count) {

    if( $count{$key} >= 2  ) { 

        print "$key found $count{$key} times in $keys"; 
        get_keys($key);
        print( "\n" );
    }
}
