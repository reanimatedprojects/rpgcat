package RPGCat::View::Fragment;
use Moose;
use namespace::autoclean;

use RPGCat;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    render_die => 1,
    INCLUDE_PATH => [
        RPGCat->path_to( 'templates', 'library' ),
    ],
);

=head1 NAME

RPGCat::View::Fragment - TT View for RPGCat

=head1 DESCRIPTION

TT View for RPGCat. It only renders fragments from the templates/library
directory and doesn't wrap the result in anything.

=head1 SEE ALSO

L<RPGCat>

=head1 AUTHOR

Simon Amor <simon@leaky.org>

=head1 LICENSE

This program is free software; but please see the LICENSING file for
more information.

=cut

1;
