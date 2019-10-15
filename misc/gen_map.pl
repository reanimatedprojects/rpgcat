#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Config::JFDI;
use RPGCat::Schema;

use Data::Dumper;
use GD::Image;

# Default tiles
my @tiles = (
    { r => 128, g => 128, b => 128, name => "Rocks", id => 1 },
    { r => 0, g => 0, b => 255, name => "Water", id => 2 },
    { r => 255, g => 0, b => 0, name => "Camp", id => 3 },
    { r => 255, g => 255, b => 255, name => "Grass", id => 4 },
    { r => 0, g => 128, b => 0, name => "Forest", id => 5 },
    { r => 192, g => 128, b => 0, name => "Tunnel", id => 6 },
);

my $map_name = shift @ARGV || "map.png";
if (! -f $map_name) {
    die "Map file not found.\n";
}

my $config = Config::JFDI->new(
    name => "RPGCat", path => "$FindBin::Bin/..",
    substitute => {
        ENV => sub {
            my $c = shift;
            if (!defined $ENV{$_[0]}) {
                die "ENV $_[0] missing";
            }
            return $ENV{$_[0]};
        }
    },
)->get;
my $dsn = $config->{'Model::DB'}{connect_info};
my $app = RPGCat::Schema->connect($dsn)
    or die "Failed to connect to database.\n";

print "Connected to database.\n";

my $map = $app->resultset("Map");
if ($map->count > 0) {
    die "Already got a map! You can't replace an existing map.\n";
}
print "No map. Preparing for map generation.\n";

my $tile_type = $app->resultset("TileType");
print "Tiles: ", $tile_type->count, "\n";
if ($tile_type->count > 0 && $tile_type->count != scalar(@tiles)) {
    die "Already got tile types but not the right number! You can't replace existing files.\n";
}

if ($tile_type->count == 0) {
    print "No tile types. Preparing for tile generation.\n";
}

my %tile_lookup = ();
foreach my $tile (@tiles) {
    my $new_tile = $tile_type->update_or_create({
        tile_type_id => $tile->{ id },
        name => $tile->{ name },
        move_type => "walking", ## because it's not implemented
        colour_code => sprintf("%2.2X%2.2X%2.2X", $tile->{ r }, $tile->{ g }, $tile->{ b }),
    });

    my $idx = join ",", $tile->{ r }, $tile->{ g }, $tile->{ b };
    $tile_lookup{ $idx } = $new_tile;
}

# Make it default to true colour images
GD::Image->trueColor(1);

my $image = eval { GD::Image->new($map_name); };
if ($@) {
    die "Failed to load map image $map_name - $@\n";
}
print "Map is " . $image->width . " x " . $image->height . " tiles\n";

$| = 1;

# Array of the new map data
my @new_tiles = ();

my $offset_x = int($image->width / 2);
my $offset_y = int($image->height / 2);

# Pre-flight check for checking the map image only has
# recognised colours (and builds up the new map data
# at the same time).

for (my $y = 0; $y < $image->height; $y ++) {
    printf " %3d ", $y;
    for (my $x = 0; $x < $image->width; $x ++) {
        my $col_idx = $image->getPixel($x,$y);
        my ($r,$g,$b) = $image->rgb($col_idx);

        my $tile_idx = join ",", $r, $g, $b;
        if (exists $tile_lookup{ $tile_idx }) {
            # Recognised this tile colour
            print ".";
            push @new_tiles, {
                map_x => $x - $offset_x,
                map_y => $y - $offset_y,
                map_z => 0,
                tile_type_id => $tile_lookup{ $tile_idx }->tile_type_id,
                name => $tile_lookup{ $tile_idx }->name,
            };

        } else {
            die "Unknown tile colour found $r,$g,$b\n";
        }
    }
    print "\n";
}

print "Found " . scalar(@tiles) . " unique colours.\n";

# If we get here, we're all good to add the map data.
# There are no unknown colours, all the tile types have
# been added, etc.

print "Adding new map tiles\n";

my $count = 0;
foreach my $map_tile (@new_tiles) {
    $count ++;
    $map->create($map_tile) or die "Failed to add map entry for " . $map_tile->{ map_x } . "," . $map_tile->{ map_y };
    print " $count \r" if ($count % 50 == 0);
}

print "\nDone.\n";
