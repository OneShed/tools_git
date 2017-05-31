#!/usr/bin/perl

use Local::Git 0.1 qw(:all) ;
use Getopt::Long;
use File::Basename;
use Pod::Usage;

# Print latest release tag of given application, cycle, repo.

# e.g. $ --repo /local/git/repos/cs.cmax --cycle CBLD1720 --appl CMAX_BE
# CBLD1720_CMAX_BE_13.00

my $url_rel = 'https://github.deutsche-boerse.de/rel';

## parse_arguments
##
sub parse_arguments { # {{{

    my %args;
    my @options = (
        # our own opts
        'repo:s',
        'cycle:s',
        'appl|application:s',
        'help+',
    );
    if ( not GetOptions( \%args, @options) ) {
        pod2usage(2);
    }
    pod2usage(1) if $args{help};
    pod2usage(2) if @ARGV;

    repo( $args{repo} ) or pod2usage(2);
    cycle( $args{cycle} ) or pod2usage(2);
    application( $args{appl} ) or pod2usage(2);

    return %args;
} # }}}

# getter/setter for __cycle 
my $__cycle;
sub cycle # {{{
{
    my($flag) = @_;
    $__cycle = $flag if defined $flag;
    return normalize_arg( $__cycle );
} # }}}

# getter/setter for __application
my $__application;
sub application # {{{
{
    my($flag) = @_;
    $__application = $flag if defined $flag;
    return normalize_arg( $__application );
} # }}}

# trim empty characters from beginnig or/and end of string
sub normalize_arg  # {{{
{
    my($arg) = @_;

    if($arg) {
        $arg =~ s/^\s+|\s+$//;
        return $arg;
    }
} # }}}

# getter/setter for repo
my $__repo;
sub repo # {{{
{
    my($flag) = @_;
    $__repo = $flag if defined $flag;
    return normalize_arg( $__repo );
} # }}}

## main ##

parse_arguments();

my $directory = repo();
my $reponame = basename( $directory );
$url_rel = $url_rel.'/'.$reponame;

my $repo = Local::Git->repo(
    dir     => $directory,
    verbose => 0,
    dry_run => 0,
);

my $cycle = cycle();
my $appl =  application();

my $rel_tag_latest = $repo->tag_remote_latest(
    $url_rel, $cycle, $appl
);

if( $rel_tag_latest ) {
    print $rel_tag_latest;
}
else {
    exit 1;
}
