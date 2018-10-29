use utf8;
package RPGCat::Controller::API;

use Moose;
use namespace::autoclean;

use HTML::FormHandler;

use strict;
use warnings;

BEGIN { extends 'Catalyst::Controller::REST' }

__PACKAGE__->config( default => "application/json" );

=head1 NAME

RPGCat::Controller::API

=head1 DESCRIPTION

Endpoints for javascript API requests (to make the main game page more dynamic)

This module is the base of a chain for /api/ and generates the response
'Cache-Control' header that tells the client not to cache the response.

=cut

sub api_chain :Chained("/") PathPart("api") CaptureArgs(0) {
    my ($self, $c) = @_;

    # We need a character, but if there isn't one we don't
    # want to redirect to the login page because this is
    # supposed to be an API endpoint.

    $c->log->debug("api_chain") if $c->debug;
    # $self->status_not_found( $c, message => "Unknown endpoint." );

    unless ($c->user_exists) {
        $self->status_not_found( $c, message => "ERR_NO_ACCOUNT" );
        $c->detach();
    }
    if ($c->session->{ active_character }) {
        my $character = $c->model('DB::Character')->find( $c->session->{ active_character } );
        if ($character && $character->account_id == $c->user->account_id) {
            $c->stash( character => $character );
        } else {
            $self->status_not_found( $c, message => "ERR_NO_CHARACTER" );
            $c->detach();
        }
    } else {
        $self->status_not_found( $c, message => "ERR_NO_CHARACTER" );
        $c->detach();
    }

    $c->response->header('Cache-Control', 'no-cache');
}

################

=head2 begin

All requests verify the three X-LG-* headers and either return
an error (with an X-LG-Response-Code header) or allow the request
to continue through to the next part of the dispatch chain.

=cut

sub deserialize :ActionClass('Deserialize') { }

sub begin :Private {
    my ($self, $c) = @_;

    # Do some validation before deserialization

    # We're done.
    $c->forward('deserialize');
}

sub serialize :ActionClass('Serialize') { }

sub end :Private {
    my ($self, $c) = @_;

    # Nothing else really happens here
    $c->forward('serialize');
}

################

=head2 /api/action/move

Allows the character to move

=cut

sub api_action_move :Chained("api_chain") PathPart("action/move") Args(0) {
    my ($self, $c) = @_;

    $c->log->debug("api_action_move") if $c->debug;

    my $params = $c->request->params;
    my $character = $c->stash->{ character };

    my $x = (exists $params->{ x } ? $params->{ x } : 0);
    my $y = (exists $params->{ y } ? $params->{ y } : 0);
    my $z = (exists $params->{ z } ? $params->{ z } : 0);
    my $in = (exists $params->{ in } ? $params->{ in } : 0);

    # Movement is either in/out, up/down, or n/s/e/w/nw/ne/sw/se
    if ($z) {
        if ($character->move( z => $z )) {
            $self->status_ok( $c,
                entity => { success => 1, refresh => [ "map" ] }
            );
            $c->detach();
        }
        # didn't move, action output will be in their event log
        $self->status_ok( $c,
            entity => { success => 0, refresh => [] }
        );
        $c->detach();
    }
    elsif ($in) {
        if ($character->move( in => $z )) {
            $self->status_ok( $c,
                entity => { success => 1, refresh => [ "map" ] }
            );
            $c->detach();
        }
        # didn't move, action output will be in their event log
        $self->status_ok( $c,
            entity => { success => 0, refresh => [] }
        );
        $c->detach();
    }
    elsif ($x || $y) {
        # We can check it like this because if both are zero,
        # no movement is happening and that's caught below
        if ($character->move( x => $x, y => $y )) {
            $self->status_ok( $c,
                entity => { success => 1, refresh => [ "map" ] }
            );
            $c->detach();
        }
        # didn't move, action output will be in their event log
        $self->status_ok( $c,
            entity => { success => 0, refresh => [] }
        );
        $c->detach();
    }
    # Successfully did nothing, no refresh required
    $self->status_ok( $c,
        entity => { success => 1, refresh => [ ] }
    );
    $c->detach();
}

=head2 /api/action/use

=head2 /api/output/map

Output the HTML fragment for the map

=cut

sub api_action_use :Chained("api_chain") PathPart("action/use") Args(0) {
    my ($self, $c) = @_;

    # Nothing works yet for using items

    $c->stash( json => { success => 0, refresh => [ ] });
}

=head2 /api/output/map

Output the HTML fragment for the map

=head2 /api/output/description

Output the HTML fragment for the location description

=head2 /api/output/inventory

Output the HTML fragment for the inventory

=head2 /api/output/events

Output the HTML fragment for the new events

=cut

sub api_output_map :Chained("api_chain") PathPart("output/map") Args(0) {
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
    $c->stash( map => $map );

    my $html = $c->forward("View::Fragment", "render", [ "fragment/map", $c->stash ]);
    # Successfully processed the map fragment.
    $self->status_ok($c,
        entity => { success => 1, html => $html }
    );
}

=head1 AUTHOR

Simon Amor <simon@leaky.org>

=head1 LICENSE

This program is free software; but please see the LICENSING file for
more information.

=cut

1;
