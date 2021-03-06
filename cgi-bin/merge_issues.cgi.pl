#!/usr/bin/perl

# {{{

=head1 NAME

cycle_comp.pl

=head1 SYNOPSIS

merge_issues_cgi.pl?opt=value

=over

=back

=head1 EXAMPLE

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
use Data::Dumper;

use Time::Local;
use Data::Dumper;
use Getopt::Long;
use Pod::Usage;

use File::stat;
use Time::localtime;

# Parse this file to get web output
use constant SOURCE => '/vobstore/disk9/statistics/merge_issues.json';

my $last_update;

# Global vars:
my $cgi = CGI->new() or throw("Failed to create CGI object");
my $csv =  $cgi->param('csv');

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

# Read a file and return it's content in $file string.
sub read_file { # {{{
    my( $file_name ) = @_;

    open my $file_handle, '<', $file_name  or
    exit_error("Cannot open file for read $file_name: $!");

    $last_update = ctime(stat($file_handle)->mtime);

    my $file=join "\n", <$file_handle>;

    close $file_handle or warn "Cannot close file handle after reading";
    return $file;
} # }}}

# Create the HTTP response
sub render_page { # {{{

    my( %issues) = @_;

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
<h2>EPR merge issues</h2>
<div align="right">
<a href="?csv=1" align="right">Download as CSV file</a> (will contain full details)
</div>

Last update: $last_update
</p>
<hr>
EOF

# issues table

    $page .= <<EOF;
</tbody>
</table>
EOF

    $page .= add_tables( %issues );

    $page .= <<'EOF';
</div>
<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
<!-- Latest compiled and minified JavaScript -->
<script src="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
<script src="//cdn.datatables.net/1.10.3/js/jquery.dataTables.min.js"></script>
<script>
$(document).ready(function() {
   $("#issues").DataTable( {"paging": false} );
}
);

<hr>
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

# Transform the %issues hash to cvs string
sub render_csv { # {{{
    my( $data ) = @_;

    # content
    my %data = %{$data};
       for my $cycle( sort keys %data ) {

        @repos = sort keys $data{$cycle};

        my $issue;
        my $table="\nCycle:,Application:,Issue:,Timestamp:\n";
        for my $repo ( sort @repos ) {

            $issue_content=$data{$cycle}{$repo};
            $table.="$cycle,$repo,$issue_content\n";
        }
        $page.=$table;
    }
    print $page;

} # }}}

sub add_tables {
    my( %issues ) = @_;
    my $msg;

    for my $cycle( sort keys %issues ) {

        @repos = keys $issues{$cycle};

        my $issue;
        for my $repo ( sort @repos ) {
            $issue_content = $issues{$cycle}{$repo};
            $issue .="<tr><td>$repo</td><td>$issue_content</td></tr>\n";
        }

        my $message = <<'MESSAGE';
<table class="table table-condensed table-bordered" id="issues">
<thead>
MESSAGE

        $message .="<th>$cycle</th>";

        $message .= <<'MESSAGE';
    <th></th>
</thead>
<thead>
    <th>Application</th>
    <th>Issue</th>
</thead>
MESSAGE

        $message .= $issue;

        $message .= <<'MESSAGE';
<tbody>
</tbody>
</table>
MESSAGE

        $msg .= $message;

    }
    return $msg;
}

sub json_to_hash { # {{{

    my( $source ) = @_;
    my $content = read_file($source);

    my %issues = %{decode_json($content)};

    return \%issues;
} # }}}

main();
sub main { # {{{

    my %issues;

    assert_arguments();
    my %issues = %{json_to_hash( SOURCE )};

    if( $csv ) {
        my $filename = "merge_issues.csv";
        my $save_as = "attachment; filename=\"$filename\"" ;
        print $cgi->header(
            -type => 'text/csv',
            -Content_disposition => $save_as,
        );
        render_csv( \%issues );
    }
    else {
        print $cgi->header('text/html');
        render_page( %issues );
    }
} # }}}
