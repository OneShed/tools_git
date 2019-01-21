#!/usr/bin/perl

# {{{

=head1 NAME

build_apps.cgi.pl - Generate a nice grep of /vobs/CFM/tools/BUILD_SCRIPTS of
live apps.

=head1 SYNOPSIS

build_apps.cgi.pl

=over

=back

=head1 RETURN VALUE

Return 0 when OK, non-zero value on error

=head1 AUTHOR

Jan Spatina <jan.spatina@deutsche-boerse.com>

=head1 LICENSE

Copyright 2014 Deutsche Boerse Services s.r.o.
Copyright 2014 Clearstream Services S.A.

=head1 HISTORY

=item 09/06/2016 Jan Spatina Creation

=cut

# }}}

use strict;
use warnings;

use 5.008;
use CGI;
use CGI::Carp qw(fatalsToBrowser);

use Time::Local;
use Data::Dumper;
use List::MoreUtils qw(uniq);
use Getopt::Long;
use Pod::Usage;
use Local::Tools qw(:all);
use Local::CC qw(:all);
use Local::AmadeusXML qw(:all);
use Local::CFMXML qw(:all);


use constant (
    BS => '/vobs/CFM/tools/BUILD_SCRIPTS/*'
);

use constant (
    CFM_WWW => '/net/clearcase/clearcase/apache/cfm-tools/cfm_live',
);
use constant (
    AMADEUS_XML =>'/net/clearcase/clearcase/apache/cfm-tools/cfm_live/vobs/CFM/tools/Amadeus.xml',
);
use constant (
    CFM_XML =>'/net/clearcase/clearcase/apache/cfm-tools/cfm_live/vobs/CFM/tools/CFM.xml',
);

my $cgi = CGI->new() or throw("Failed to create CGI object");

sub get_live_apps { # {{{

    my($env) = @_;

    my $extract = Local::AmadeusXML->parse(AMADEUS_XML) or die "Error: $@";

    my @apps;
    my @applications = $extract->applications;
    foreach my $app (@applications) {
        if( $app->active && $app->env eq $env ) {
            push @apps, $app->name;
        }
    }
    return @apps;
} # }}}


my $cfm = Local::CFMXML->parse(CFM_XML);
my @non_cfm;

sub parse_build_script { # {{{
    my( $env ) = @_;
    assert( 
        $env eq 'UNIX'
        || 
        $env eq 'NT'
    );

    my %app_matrix;

    my @live_apps = get_live_apps( $env );

    foreach my $app_name ( @live_apps ) {

        my $app;
        eval {
            $app = $cfm->lookup_application($app_name, $env);
        };
        if($@) {
            # non CFM controlled
            push @non_cfm, "$app_name-$env";
            next;
        }
	my @bs_full = map { CFM_WWW.$_ } $app->build_script;

	# if appliction is sourcing other scritps, add it to this section

	
	if( $app_name eq 'AM' ) {
		my $bs_full = sprintf( "%s%s", CFM_WWW, '/vobs/CFM/tools/BUILD_SCRIPTS/am.ca' );
		@bs_full = ( $bs_full );
	}
	elsif( $app_name eq 'RDF' ) {

		my $bs_full = sprintf( "%s%s", CFM_WWW, '/vobs/CFM/tools/BUILD_SCRIPTS/rdf_all.ca' );
		@bs_full = ( $bs_full );
}
elsif( $app_name eq 'TI_LINUX' or $app_name eq 'TI_RHEL7' ) {
		my $bs_full = sprintf( "%s", '/view/default/opt/creation/dev/server/ti/cmenv/tools/ti_build' );
		@bs_full = ( $bs_full );
}
elsif( $app_name eq 'PDFSERVICE' ) {
		my $bs_full = sprintf( "%s", '/view/default/vobs/PDFService/Application/build.ksh' );
		@bs_full = ( $bs_full );
}

elsif( $app_name eq 'PI2' ) {
		my $bs_full = sprintf( "%s%s", CFM_WWW , '/vobs/CFM/tools/BUILD_SCRIPTS/pi2.ca' );
		@bs_full = ( $bs_full );
}

elsif( $app_name eq 'CMAX_BE' ) {
		my $bs_full = sprintf( "%s%s", CFM_WWW , '/vobs/CFM/tools/BUILD_SCRIPTS/cmax_be.ca' );
		@bs_full = ( $bs_full );
}

elsif( $app_name eq 'COCP_FMWK' ) {
		my $bs_full = sprintf( "%s%s", CFM_WWW , '/vobs/CFM/tools/BUILD_SCRIPTS/cocp_fmwk.ca');
		@bs_full = ( $bs_full );
}

elsif( $app_name eq 'GUM' ) {
		my $bs_full = sprintf( "%s%s", CFM_WWW , '/vobs/CFM/tools/BUILD_SCRIPTS/gum.ca' );
		@bs_full = ( $bs_full );
}
elsif( $app_name eq 'NCMS' ) {
		my $bs_full = sprintf( "%s%s", CFM_WWW , '/vobs/CFM/tools/BUILD_SCRIPTS/ncms.ca' );
		@bs_full = ( $bs_full );
}
elsif( $app_name eq 'MQ_EXTRACTOR' ) {
		my $bs_full = sprintf( "%s%s", CFM_WWW , '/vobs/CFM/tools/BUILD_SCRIPTS/mq_extractor.ca');
		@bs_full = ( $bs_full );
}
elsif( $app_name eq 'RDF_KERNEL' ) {
		my $bs_full = sprintf( "%s%s", CFM_WWW , '/vobs/CFM/tools/BUILD_SCRIPTS/rdf_kernel.ca');
		@bs_full = ( $bs_full );
}
elsif( $app_name eq 'CLAIMS' ) {
		my $bs_full = sprintf( "%s" , '/view/default/vobs/CLAIMS/Eclipse-workspace/PSSPj/make.sh' ); 
		@bs_full = ( $bs_full );
}

elsif( $app_name eq 'CODELIST' ) {
		my $bs_full = sprintf( "%s" , '/view/default/vobs/stargate/scripts/Ant/build.sh');
		@bs_full = ( $bs_full );
}
elsif( $app_name eq 'CODELISTLUX' ) {
		my $bs_full = sprintf( "%s" , '/view/default/vobs/CodeListLux/source/make.sh' );
		@bs_full = ( $bs_full );
}
elsif( $app_name eq 'CUSTODY_WEB' ) {
		my $bs_full = sprintf( "%s" , '/view/default/vobs/Custody_Web/Eclipse-workspace/Custody/custody.sh');
		@bs_full = ( $bs_full );
}

elsif( $app_name eq 'STARGATE_HUB' ) {
		my $bs_full = sprintf( "%s" , '/view/default//vobs/eGate/Hub/build.ksh');
		@bs_full = ( $bs_full );
}

elsif( $app_name eq 'STARGATE' ) {
		my $bs_full = sprintf( "%s" , '/view/default/vobs/stargate/scripts/Ant/build.sh');
		@bs_full = ( $bs_full );
}

elsif( $app_name eq 'CDIRECT_EOC' ) {
		my $bs_full = sprintf( "%s" , '/view/default/vobs/cdirect/build/buildRelease.ksh');
		@bs_full = ( $bs_full );
}

elsif( $app_name eq 'DATASERVER_RDFL' ) {
		my $bs_full = sprintf( "%s" , '/view/default/vobs/DATASERVER_RDFL/build.sh' );
		@bs_full = ( $bs_full );
}

	# end of the section

	if( @bs_full ) {
            my $found;
	    my $nonexist;

            foreach my $bs (@bs_full) {

if( ! -e $bs ) {
	$nonexist = TRUE; 
next;
}
else {
$nonexist = FALSE;
}
                my $maven = qr/^mvn|\\mvn|generic_(nexus|maven)_appl.sh|mvn_appl_win.pl|do_maven/;

                if( grep_file( $bs, $maven )){
                    push @{$app_matrix{maven}}, $app_name;
                    $found = TRUE;
                }
                elsif( grep_file( $bs, qr/^ant|\/ant|\\ant|\\nant/ )) {
                    push @{$app_matrix{ant}}, $app_name;
                    $found = TRUE;
                }
                elsif( grep_file( $bs, qr/^gradle/ )) {
                    push @{$app_matrix{gradle}}, $app_name;
                    $found = TRUE;
                }
                elsif( grep_file( $bs, qr/^clearmake|xpather/ )) {
                    push @{$app_matrix{clearmake}}, $app_name;
                    $found = TRUE;
                }
                elsif( $bs =~ /Powerbuilder.txt/ ) {
                    push @{$app_matrix{powerbuilder}}, $app_name;
                    $found = TRUE;
                }
            }
            if( ! $found && $nonexist != TRUE ) {
                push @{$app_matrix{to_be_checked}}, $app_name;
            }
        }
        else {
            push @{$app_matrix{non_build}}, $app_name;
        }
    }

    $app_matrix{total} = scalar @live_apps;

    return %app_matrix;
} # }}}

sub grep_file { # {{{
    my( $file, $what ) = @_;

    my @lines;
    return if ( !-e $file); 

    file_read(
        file  => $file,
        lines => \@lines,
    ) or throw("Read failed");

    if( grep ( /$what/, @lines )) {
        return TRUE;
    }
} # }}}

my %matrix_unix = parse_build_script('UNIX');
my %matrix_nt = parse_build_script('NT');
my $total = $matrix_unix{total} + $matrix_nt{total};

# render html

sub print_section { # {{{
    my( $env, $section ) = @_;
    my $mat_sub = ($env eq 'UNIX') ? $matrix_unix{$section} : $matrix_nt{$section};

    if($mat_sub) {
        my $total = sprintf " (%s)", scalar @{$mat_sub};
        print $cgi->h4($section. $total ); 

        foreach( uniq( @{$mat_sub} ) ) {
            print "$_<br>";
        }
    }
} # }}}

my $total_non_cfm = sprintf " (%s)", scalar @non_cfm;

print $cgi->header('html');
print $cgi->start_html('Active applications');
print $cgi->h2("Active applications ($total), non CFM controlled $total_non_cfm");

my $unix_total = $matrix_unix{total};
print $cgi->h3('UNIX'." ($unix_total)");

print_section('UNIX','maven');
print_section('UNIX','ant');
print_section('UNIX','clearmake');
print_section('UNIX','to_be_checked');
print_section('UNIX','non_build');

my $nt_total = $matrix_nt{total};
print $cgi->h3('NT'." ($nt_total)");

print_section('NT','maven');
print_section('NT','ant');
print_section('NT','clearmake');
print_section('NT','powerbuilder');
print_section('NT','to_be_checked');
print_section('NT','non_build');

print $cgi->h4('Non CFM controlled'. $total_non_cfm);

foreach (@non_cfm) {
print "$_<br>";
}
$cgi->end_html;
