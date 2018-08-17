package RPGCat::Controller::Static;

use Moose;
use namespace::autoclean;

use HTML::FormHandler;

BEGIN { extends 'Catalyst::Controller' }

=head1 NAME

RPGCat::Controller::Static

=head1 DESCRIPTION

Static pages get linked here because they're not quite static - we still have
a few things that can change depending on whether you're logged in, etc.

=head2 /about

The 'about rpgcat' page - replace the content with your own game's about
page.

=cut

sub about_page :Chained("/") PathPart("about") Args(0) {
    my ($self, $c) = @_;

    $c->stash( template => "about.html" );
}

=head1 AUTHOR

Simon Amor <simon@leaky.org>

=head1 LICENSE

This program is free software; but please see the LICENSING file for
more information.

=cut

1;
