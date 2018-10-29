package RPGCat::Model::EMKit;

use strict;
use warnings;

use base 'Catalyst::Model::Factory';

use RPGCat::EMKit;
use Moose;
use Types::Standard qw(HashRef Maybe Str);

=head1 NAME

RPGCat::Model::EMKit - Catalyst model for sending emails

=head1 DESCRIPTION

This module provides a way to access RPGCat::EMKit and send emails. It
is based on (copied from) Sendme::Model::EMKit found at
https://github.com/simonamor/catalyst-example-email/

=head1 METHODS

=cut

our $AUTOLOAD;

has 'EmailInstance' => (
    is => 'rw',
    isa => 'RPGCat::EMKit',
);

=head1 ATTRIBUTES

=over 4

The following are properties that this model provides, only the
from_email is required. The others have reasonable defaults.

=over 4

=item * from_email - the default From address

=item * from_name - the default From name

=item * default_transport - which class to use to send email

=item * default_transport_args - any extra args for the transport

=item * template_path - __PACKAGE__->path_to('emails')->stringify

=back

These would normally be defined in your application module as follows:

    __PACKAGE__->config(
        'Model::EMKit' => {
            default_from_email => 'rpgcat@localhost',
            default_from_name => 'RPGCat',
            default_transport => 'Email::Sender::Transport::Sendmail',
            default_transport_args => undef,
            template_path => __PACKAGE__->path_to('emails')->stringify,
        },
    );

The email transport and args can also be defined in environment variables

    EMAIL_SENDER_TRANSPORT=SMTP
    EMAIL_SENDER_TRANSPORT_HOST=127.0.0.1
    EMAIL_SENDER_TRANSPORT_PORT=25

Another option is to define these in the rpgcat.yaml

    Model::EMKit:
        default_transport: Email::Sender::Transport::SMTP
        default_transport_args:
            host: 127.0.0.1
            port: 25

=head2 default_from

This should be just an email address. Ideally one that is able
to receive replies so you get any bounces that may be generated.

=cut

has 'from_email' => (
    is => 'ro',
    isa => Str,
    default => 'rpgcat@localhost',
);

has 'from_name' => (
    is => 'ro',
    isa => Str,
    default => 'RPGCat',
);

=head2 default_transport

You will almost definitely want to use something that isn't
Email::Sender::Transport::Test during normal use otherwise
you won't get any emails!

=cut

has 'default_transport' => (
    is => 'rw',
    isa => Str,
    default => 'Email::Sender::Transport::Test',
);

has 'default_transport_args' => (
    is => 'rw',
    isa => Maybe[HashRef],
    default => undef,
);

=head2 template_path

The base directory where the Email::MIME::Kit template directories
are to be found.

=cut

has 'template_path' => (
    is => 'rw',
    isa => Str,
    default => '.',
);

__PACKAGE__->config( class => "RPGCat::Model::EMKit" );

=head2 ACCEPT_CONTEXT

This ensures that any requests for $c->model('EMKit') return a fresh
object that hasn't already been referenced.

=cut

# One instance per $c->model() request
sub ACCEPT_CONTEXT {
    my ($self, $c, @args) = @_;
    my $emkit = RPGCat::EMKit->new(
        template_path => $self->template_path,
        default_from_name => $self->from_name,
        default_from_email => $self->from_email,
        transport_class => $self->default_transport,
        transport_args => $self->default_transport_args,
        @args );

    return $emkit;
}

=head2 AUTOLOAD

Any methods requested are passed through to RPGCat::EMKit

=cut

sub AUTOLOAD {
    my $self = shift;
    my $name = $AUTOLOAD;
    $name =~ s/.*://;
    $self->EmailInstance->$name(@_);
}

=head1 AUTHOR

Simon Amor <simon@leaky.org>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the terms of either:

    a) the GNU General Public License as published by the Free
    Software Foundation; either version 1, or (at your option) any
    later version, or

    b) the "Artistic License" version 2 which comes with this program.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either
the GNU General Public License or the Artistic License for more details.

You should have received a copy of the Artistic License with this
program in the file named "LICENSES/Artistic-2_0". If not, please visit
http://www.perlfoundation.org/artistic_license_2_0

You should also have received a copy of the GNU General Public License
along with this program in the file named "LICENSES/Copying". If not,
write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
Boston, MA 02110-1301, USA or visit their web page on the internet at
http://www.gnu.org/copyleft/gpl.html

=cut

1;
