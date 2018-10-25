package RPGCat::Controller::Map;

use Moose;
use namespace::autoclean;

use HTML::FormHandler;

BEGIN { extends 'Catalyst::Controller' }

=head1 NAME

RPGCat::Controller::Map

=head1 DESCRIPTION

Map related pages - view, move

=cut

sub map_chain :Chained("/") PathPart("map") CaptureArgs(0) Does('NeedsCharacter') {
    my ($self, $c) = @_;

}

=head2 /map

=cut

sub map_index :Chained("map_chain") PathPart("") Args(0) {
    my ($self, $c) = @_;

    my $character = $c->stash->{ character };
    my $map_rs = $c->model('DB::Map')->search({
        map_x => { '>=' => $character->map_x - 2 },
        map_x => { '<=' => $character->map_x + 2 },
        map_y => { '>=' => $character->map_y - 2 },
        map_y => { '<=' => $character->map_y + 2 },
    }, { order_by => [ 'map_y', 'map_x' ] });
    my $map = { };
    while (my $tile = $map_rs->next) {
        $map->{ $tile->map_x }{ $tile->map_y } = $tile;
    }

    $c->stash(
        map => $map,
        template => "map/index.html",
    );
}

=head1 AUTHOR

Simon Amor <simon@leaky.org>

=head1 LICENSE

This program is free software; but please see the LICENSING file for
more information.

=cut

1;
