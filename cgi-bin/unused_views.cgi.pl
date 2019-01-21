#!/usr/bin/perl

# {{{

=head1 NAME

unused_views.cgi.pl - Parse views.json to create html output of views
that have 'last_accessed' value before given time.

=head1 SYNOPSIS

unused_views.cgi.pl?days=<days> 

=over

=back

=head1 EXAMPLE

http://vmdevcfm/unused_views.cgi.pl?days=90

=head1 RETURN VALUE

Return 0 when OK, non-zero value on error

=head1 AUTHOR

Jan Spatina <jan.spatina@deutsche-boerse.com>

=head1 LICENSE

Copyright 2014 Deutsche Boerse Services s.r.o.
Copyright 2014 Clearstream Services S.A.

=head1 HISTORY

=item 01/20/2015 Jan Spatina Creation

=cut

# }}}

use 5.008;
use JSON;
use CGI;
use CGI::Carp qw(fatalsToBrowser);

use Time::Local;
use Data::Dumper;
use Getopt::Long;
use Pod::Usage;

# Parse this file to get web output
use constant SOURCE => '/vobstore/disk9/statistics/ClearCaseStats/Data/views.json';

# Global vars:
my $cgi = CGI->new() or throw("Failed to create CGI object");
my $web_days = $cgi->param('days');
my $csv_days =  $cgi->param('csv');

# Use only positive integer in href '?days=<days>'
sub assert_arguments # {{{
{
    if( ($web_days !~ m/^[0-9]*$/) && !$csv_days ) {
        print $cgi->header,
        $cgi->start_html(), # start the HTML
        $cgi->h1("Wrong value inserted: $web_days, insert positive integer"),
        $cgi->end_html;
        exit 1;
    }
} # }}}

# Parse the JSON string to hash array $tag<=>[$option<=>$value],
# Values to be accessed via $view{$tag}->{last_accessed}.
sub parse_json_to_hash { # {{{

    my( $json ) = @_;
    my %view_hash_whole;
    my %view_hash;
    my $tag;

    my @views = @{decode_json(${$json})};

    foreach my $view_array( @views ) {

        my %view_hash = %{$view_array};

        $tag = $view_hash{tag} or exit_error('Missing tag in JSON section');

        $view_hash_whole{$tag} = \%view_hash;
    }
    return \%view_hash_whole;
} # }}}

# Encode the hash array into pretty text output.
sub json_pretty_encode { # {{{
    my( $data ) = @_;

    my $json = JSON->new->allow_nonref;
    my $pretty_json = $json->pretty->encode( $data );
    return $pretty_json;
} # }}}

# Calculate the number of days between given and current time.
sub day_difference { # {{{

    my( %args ) = @_;

    my $my_time = timelocal(
        $args{second},
        $args{minute},
        $args{hour},
        $args{day},
        $args{month}-1,
        $args{year},
    );

    my $time = time();
    return int( ($time - $my_time)/86400);
} # }}}

# Read a file and return it's content in $file string.
sub read_file { # {{{
    my( $file_name ) = @_;

    open my $file_handle, '<', $file_name  or
    exit_error("Cannot open file for read $file_name: $!");

    my $file=join "\n", <$file_handle>;

    close $file_handle or warn "Cannot close file handle after reading";
    return $file;
} # }}}

# Parse the time string, e.g. 2014-10-31T21:50:10+01:00
# to hash [ year=>\d{4}, month=>d{2} ... ]
sub parse_time { # {{{
    my( $time_string ) = @_;
    my %time;

    my $time_regexp = qr{
    ^(\d{4}) # $1 year
    -
    (\d{2})  # $2 month
    -
    (\d{2})  # $3 day
    T
    (\d{2})  # $4 hour
    :
    (\d{2})  # $5 minute
    :
    (\d{2})  # $6 second
    +.*$
    }x;      # ignore whitespaces and newlines

    if( $time_string =~ /$time_regexp/ ) {

        $time{year}=$1;
        $time{month}=$2;
        $time{day}=$3;
        $time{hour}=$4;
        $time{minute}=$5;
        $time{second}=$6;
    }
    return %time;
} # }}}

# Create the HTTP response
sub render_page { # {{{

    my( $data, $views_count ) = @_;

# header
    my $page = <<EOF;
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css">
<link rel="stylesheet" href="//cdn.datatables.net/1.10.3/css/jquery.dataTables.min.css">

<!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
<!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
<!--[if lt IE 9]>
<script src="//oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
<script src="//oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
<![endif]-->

<script>
function days_value() {
    var days_given=document.getElementById("days").value;
    var param="?days="+days_given;
    window.location=param;
    }
    </script>

</head>

<body>
<div class="container">
<p>
<h2>Views not accessed for more than $web_days days: $views_count in total</h2>
<div align="right">
<a href="?csv=$web_days" align="right">Download as CSV file</a> (will contain full details)
</div>

</p>
<hr>
      <label>Change number of days: </label><br>
      <input type="text" size="6" maxlength="4" onkeyup="if(event.keyCode==13) days_value()" id="days" value=$web_days>
EOF

# views table

    $page .= <<EOF;
<table class="table table-condensed table-bordered" id="views">
<thead>
    <th>Owner</th>
    <th>View</th>
    <th>Group</th>
</thead>
<tbody>
EOF

    my %data = %{$data};
    my $owner;
    my $group;

    my $views;
    foreach my $view_owner( keys %data) {
        $views = join ', ', @{$data{$view_owner}};

        # view_owner: devl/hm410, OAAD\\hm410 ...
        if( $view_owner =~ m/^(.*)(\/|\\)(.*)$/ ) {
            $group = $1;
            $owner = $3;
            $page .="<tr><td>$owner</td><td>$views</td><td>$group</td></tr>\n";
        }
    }

    $page .= <<EOF;
</tbody>
</table>
EOF

# footer
    $page .= <<'EOF';
</div>
<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
<!-- Latest compiled and minified JavaScript -->
<script src="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
<script src="//cdn.datatables.net/1.10.3/js/jquery.dataTables.min.js"></script>
<script>
$(document).ready(function() {
   $("#views").DataTable( {"paging": false} );
}
);
</script>

</body>
</html>
EOF

    print $page;
} # }}}

# Die with $err to stderr.
sub exit_error { # {{{

    my( $err ) = @_;
    die( $err );
} # }}}

# Transform the %view hash to cvs string
sub render_csv { # {{{
    my( $data ) = @_;

    # header
    my $page= "Group,Owner,View\n";


    # content
    my %data = %{$data};
    my $views;
    foreach my $owner( keys %data ) {

        $owner =~ /(.*)(\/|\\)(.*)$/;
        $views = join "\n,,", @{$data{$owner}};
        $page .= "$1,$3,$views\n";
    }
    print $page;

} # }}}

# Execution starts here.

main();
sub main { # {{{

    my $last_accessed;
    my @json;
    my %view; # Hash of arrays $view_owner<=>[$tag1,$tag2...]
    my $views_count;

    assert_arguments();
    my $file_source = read_file(SOURCE);
    my %data = %{parse_json_to_hash( \$file_source )};

    my $days = $csv_days? $csv_days : $web_days;

    foreach my $tag( keys %data) {
        $last_accessed = $data{$tag}{last_accessed};

        # could be missing due to some exotic hosts
        if( $last_accessed ) {
            # if $days == 0, skip the difference counting => list all views
            if( day_difference(parse_time( $last_accessed )) > $days) {

                my $view_owner = $data{$tag}{view_owner};
                push @{$view{$view_owner}}, $tag;
                $views_count++;
            }
        }
    }
    if( $csv_days ) {
        my $filename = "obsolete_views_$csv_days.csv";
        my $save_as = "attachment; filename=\"$filename\"" ;
        print $cgi->header(
            -type => 'text/csv',
            -Content_disposition => $save_as,
        );
        render_csv( \%view );
    }
    else {
        print $cgi->header('text/html');
        render_page( \%view, $views_count );
    }
} # }}}
