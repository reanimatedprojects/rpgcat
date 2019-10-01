#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use RPGCat;

select(STDERR);
$| = 1;
select(STDOUT);
$| = 1;

my $app = RPGCat->apply_default_middlewares(RPGCat->psgi_app);
$app;

