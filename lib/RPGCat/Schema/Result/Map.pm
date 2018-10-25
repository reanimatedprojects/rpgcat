use utf8;
package RPGCat::Schema::Result::Map;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

__PACKAGE__->table("maps");

__PACKAGE__->add_columns(
    "map_id",
    {data_type => "integer",extra => { unsigned => 1 }, is_nullable => 0, is_auto_increment => 1 },
    "map_x",
    {data_type => "integer",extra => { unsigned => 0 }, is_nullable => 0},
    "map_y",
    {data_type => "integer",extra => { unsigned => 0 }, is_nullable => 0},
    "map_z",
    {data_type => "integer",extra => { unsigned => 0 }, is_nullable => 0},
    "tile_type_id",
    { data_type => "integer", extra => { unsigned => 0 }, is_nullable => 0 },
    "name",
    { data_type => "char", size => 64, is_nullable => 1 },
);

__PACKAGE__->set_primary_key("map_id");

__PACKAGE__->add_unique_constraint("map_coords" => ["map_x","map_y","map_z"]);

__PACKAGE__->belongs_to( 'tile_type' => 'RPGCat::Schema::Result::TileType', 'tile_type_id' );

__PACKAGE__->meta->make_immutable;
1;
