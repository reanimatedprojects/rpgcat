use utf8;
package RPGCat::Schema::Result::TileType;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

__PACKAGE__->table("tile_types");

__PACKAGE__->add_columns(
    "tile_type_id",
    {data_type => "integer",extra => { unsigned => 1 }, is_auto_increment => 1, is_nullable => 0},
    "name",
    { data_type => "char", is_nullable => 0, size => 32 },
    "colour_code",
    { data_type => "char", size => 6, is_nullable => 0 },
    "move_type",
    { data_type => "char", size => 10, is_nullable => 0 },
);


__PACKAGE__->set_primary_key("tile_type_id");

__PACKAGE__->has_one( 'description' => 'RPGCat::Schema::Result::TileTypeDescription', 'tile_type_id' );

__PACKAGE__->meta->make_immutable;
1;
