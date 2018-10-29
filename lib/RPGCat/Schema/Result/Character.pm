use utf8;
package RPGCat::Schema::Result::Character;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

__PACKAGE__->table("characters");

__PACKAGE__->add_columns(
  "character_id",
  {data_type => "integer", extra => { unsigned => 1 }, is_auto_increment => 1, is_nullable => 0 },
  "character_name",
  { data_type => "char", is_nullable => 0, size => 32 },
  "account_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "character_health",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "character_exp",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "character_max_ap",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "character_ap",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },

    "map_x",
    { data_type => "integer", extra => { unsigned => 0 }, is_nullable => 0, default => 0 },
    "map_y",
    { data_type => "integer", extra => { unsigned => 0 }, is_nullable => 0, default => 0 },
    "map_z",
    { data_type => "integer", extra => { unsigned => 0 }, is_nullable => 0, default => 0 },
);



__PACKAGE__->set_primary_key("character_id");

__PACKAGE__->add_unique_constraint("character_name", ["character_name"]);

__PACKAGE__->has_one( 'location' => 'RPGCat::Schema::Result::Map',
    {
        'foreign.map_x' => 'self.map_x',
        'foreign.map_y' => 'self.map_y',
        'foreign.map_z' => 'self.map_z',
    }
);

__PACKAGE__->belongs_to( 'account' => 'RPGCat::Schema::Result::Account', 'account_id' );
__PACKAGE__->might_have( 'inventory' => 'RPGCat::Schema::Result::Inventory', 'character_id' );

sub move {
    my $self = shift;
    my $args = $_[0] && ref $_[0] eq 'HASH' ? shift : { @_ };

    # check for z movement


    # check for x,y movement
    if (exists $args->{ x } || exists $args->{ y }) {
        $args->{ x } = 0 unless exists $args->{ x };
        $args->{ y } = 0 unless exists $args->{ y };

        # This limits movement to 1 tile at a time in any direction.
        unless ($args->{ x } >= -1 && $args->{ x } <= 1 &&
                $args->{ y } >= -1 && $args->{ y } <= 1) {
            return { success => 0, error => "ERR_MOVE_TOO_FAR" };
        }

        # Moving x/y
        $self->map_x( $self->map_x + $args->{ x } );
        $self->map_y( $self->map_y + $args->{ y } );
        $self->update();
        return { success => 1 };
    }

    return { success => 0, error => "ERR_BAD_DIRECTION" };
}


__PACKAGE__->meta->make_immutable;
1;
