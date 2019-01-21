#!/usr/bin/perl

use strict;
use warnings;

use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Data::Dumper;

use Local::Tools qw(:all);
use Local::CC;

#
# render_page @CLIENTS
#
# Return content of page.
#
# Template Toolkit would be much better, but this would be only script using
# it. Hence this hardcoded spaghetti mess.
#
sub render_page # {{{
{
    my (@clients) = @_;

    my $page = '';

    # header
    $page .= <<EOF;
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">

<!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
<!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
<!--[if lt IE 9]>
<script src="//oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
<script src="//oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
<![endif]-->

<link rel="stylesheet" href="//cdn.datatables.net/1.10.3/css/jquery.dataTables.min.css">
</head>
<body>
<div class="container">
<p>
<h2>ClearCase clients</h2>
<a href="?format=csv">Download as CSV file</a> (will contain full details)
</p>
<hr>
EOF

    # stats
    $page .= <<EOF;
<table class="table table-condensed table-bordered" id="stats">
<thead><th>Product</th><th>Clients</th></thead>
<tbody>
EOF
    my %stats;
    $stats{$_->product}++ for @clients;
    my @by_freq = reverse sort {
        $stats{$a} <=> $stats{$b}
    } (keys %stats);
    foreach my $product ( @by_freq ) {
        $page .= sprintf(
            "<tr><td>%s</td><td>%s</td></tr>\n",
            $product || 'unknown',
            $stats{$product},
        );
    }
    $page .= <<EOF;
</tbody>
</table>
EOF

    # clients table
    $page .= <<EOF;
<table class="table table-condensed table-bordered" id="clients">
<thead>
<th>Client</th>
<th>Region</th>
<th>Product</th>
<th>Operating system</th>
</thead>
<tbody>
EOF

    foreach my $client ( @clients ) {
        $page .= sprintf(
            "<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>\n",
            $client->name,
            $client->registry_region,
            $client->product,
            $client->os,
        );
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
   $("#clients").DataTable( {"paging": false} );
}
);
</script>

</body>
</html>
EOF

    return $page;
} # }}}

#
# render_csv @CLIENTS
#
# Return content of full-details CSV.
#
sub render_csv # {{{
{
    my @clients = @_;

    # header
    my @fields = (
        "Name",
        "Product",
        "Operating System",
        "Hardware type",
        "Registry host",
        "Registry region",
        "License host",
        "Last registry access",
        "Last license access",
    );
    my $page = join(",", @fields);
    $page .= "\n";

    # content
    foreach my $client ( @clients ) {
        $page .= join(",",
            $client->name,
            $client->product,
            $client->os,
            $client->hw,
            $client->registry_host,
            $client->registry_region,
            $client->license_host,
            $client->last_registry_access,
            $client->last_license_access,
        );
        $page .= "\n";
    }

    return $page;
} # }}}

my $q = CGI->new()
    or throw("Failed to create CGI object");

my $format = $q->param('format') || 'html';

my @clients = eval { Local::CC->get_clients() };
if ( $format eq 'csv' ) {
    my $save_as = 'attachment; filename="clearcase_clients.csv"';
    print $q->header(
        -type => 'text/csv',
        -Content_disposition => $save_as,
    );
    print render_csv(@clients);
}
else {
    print $q->header('text/html');
    print render_page(@clients);
}
