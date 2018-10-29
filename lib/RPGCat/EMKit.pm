package RPGCat::EMKit;

use Email::MIME::Kit;
use Email::Sender::Simple;
use Module::Load;

use strict;
use warnings;

=head1 NAME

RPGCat::EMKit - Email sending module

=head1 DESCRIPTION

Copied with this minor modification from

https://github.com/simonamor/catalyst-example-email/blob/master/lib/Sendme/EMKit.pm

=head1 SYNOPSIS

This module provides functionality to send an email.

    $email = RPGCat::EMKit->new({
                transport_class => 'Email::Sender::Transport::Sendmail',
            })
            ->template("welcome", {
                somevar => "a value",
            })
            ->to('"Simon" <simon@example.com>')
            ->from('"No-reply" <no-reply@example.net>')
            ->subject("Welcome to RPGCat")
            ->send();

Create a directory (this is the template name) and at a minimum, a file
called manifest.json containing the relevant details. See Email::MIME::Kit
for more information on the manifest.

=head1 METHODS

=head2 new()

Takes an optional hashref containing any of the following:

    transport_class => 'Email::Sender::Transport::Sendmail'
    transport_args => { }
    default_from_name => 'RPGCat'
    default_from_email => 'rpgcat@localhost'

An example of the transport_args would be SMTP details required for
Email::Sender::Transport::SMTP to work.

Returns $self (obviously)

=cut

sub new {
    my $class = shift;
    my $extra_args = @_ && ref($_[0]) eq 'HASH' ? shift : { @_ };

    # Default class doesn't actually send mail
    my $self = {
        transport_class => ($extra_args->{ transport_class } ||
            "Email::Sender::Transport::Test"),

        transport_args  => ($extra_args->{ transport_args } || {}),
        _template_path  => ($extra_args->{ template_path } || undef),
        _source         => undef,
        _error          => "",
        _default_args   => {
            from_email      => $extra_args->{ default_from_email },
            from_name       => $extra_args->{ default_from_name },
        },
    };

    delete $extra_args->{ transport_class }
        if exists $extra_args->{ transport_class };
    delete $extra_args->{ transport_args }
        if exists $extra_args->{ transport_args };

    # If this isn't defined, things will likely go wrong!
    if (exists $extra_args->{ template_path }) {
        $self->{ _template_path } = delete $extra_args->{ template_path };
    }
    # Clone the other args and store for later
    $self->{ _default_args }{ $_ } = $extra_args->{ $_ } foreach keys %$extra_args;

    bless $self, $class;
    return $self;
}

=head2 source

Set/Get the current template source (just a directory name)

Returns $self

=cut

sub source {
    my $self = shift;
    my $template = shift || return $self->{ _source };
    $self->{ _source } = $template;
    return $self;
}

=head2 template( <template_name>, { tmpl_arg => tmpl_value, ... } )

Takes a template name and optional args and generates the required
html/text content from the template(s) and uses the Email::Stuffer
methods html_body and text_body to set the content to send.

=cut

sub template {
    my $self = shift;
    my $template_name = shift or die "template name not provided";
    my $template_args = @_ && ref($_[0]) eq "HASH" ? shift : { @_ };

    $self->source( $template_name );

    # We need to store this since ->to() and ->from() operate on it
    $self->{ _email } = $self->_emkit->assemble( $template_args );

    # We do this here because it can't be done before the kit is assembled.
    # The values here are passed to the constructor as default_from_name and
    # default_from_email (separated because the reply-to is just the email)
    my $escaped_name = $self->{ _default_args }{ from_name };
    # Escape any double-quotes
    $escaped_name =~ s/"/\\"/g;
    my $from_address = sprintf "\"%s\" <%s>", $escaped_name, $self->{ _default_args }{ from_email };

    return $self
        ->from( $from_address )
        ->header( "Reply-To", $self->{ _default_args }{ from_email } );
}

=head2 to( <email> )

Set the To header - doesn't fail if no email is provided.

Shortcut for ->header("To", <email>)

Returns $self

=cut

sub to {
    my $self = shift;
    return $self->header("To", shift);
}

=head2 from( <email> )

Set the From header - this will override the default From header provided
by the template. Sets the From header to "" if no <email> is provided.

Shortcut for ->header("From", <email>)

Returns $self

=cut

sub from {
    my $self = shift;
    return $self->header("From", shift);
}

=head2 subject( <subj> )

Set the Subject header - this will override the default Subject header
provided by the template. Blanks the subject if no subject is provided.

Shortcut for ->header("Subject", <subj>)

Return $self

=cut

sub subject {
    my $self = shift;
    return $self->header("Subject", shift);
}

=head2 header( <header>, <string> )

Set the specified <header> to <string>. Can also be used to set the above
headers To/From/Subject if you prefer.

=cut

sub header {
    my $self = shift;
    my $hdr = shift || return $self;
    my $args = shift || "";

    $self->_email->header_str_set( $hdr => $args );
    return $self;
}

=head2 send()

Send the email using the transport_class provided to constructor

=cut

sub send {
    my $self = shift;

    # Loads the correct module
    load $self->{ transport_class };
    my $transport = $self->{ transport_class }->new($self->{ transport_args });
    my $email = $self->_email();
    my %headers = ( $email->header_str_pairs );
    my @recipients = ();
    my $sender = $headers{"From"} || "";

    foreach my $k (keys %headers) {
        push @recipients, $headers{$k} if ($k =~ /^(To|Cc|Bcc)$/i);
    }

    # Doing this here because Email::Sender::Simple's code isn't quite
    # right. I think it's because Email::Address->parse now returns
    # an array rather than a single scalar.

    # This is required for Transport::SMTP to work.
    # Transport::Sendmail isn't quite so fussy.

    # Strip any non-address part of the To addresses
    my @send_to = ();
    foreach my $t (@recipients) {
        my @eap_to = Email::Address->parse($t);
        push @send_to, map { $_->address } grep { defined } @eap_to;
    }

    # Strip any non-address part of the From address
    my @eap_from = Email::Address->parse($sender);
    if (@eap_from) {
        $sender = $eap_from[0]->address;
    }

    my $args = {
        to => \@send_to,
        from => $sender,
        transport => $transport,
    };

    my $res = eval {
        Email::Sender::Simple->send_email($email, $args);
    };
    if ($@) {
        # Failed to send
        $self->error($@);
        return undef;
    }
    $self->error("");
    return 1;
}

=head2 error( [value] )

Get/Set the error sending the message.

=cut

sub error {
    my $self = shift;
    my $value = shift;
    if (defined $value) {
        $self->{ _error } = $value;
    }
    return $self->{ _error };
}

=head1 INTERNAL METHODS

=head2 _emkit

Get the current Email::MIME::Kit object. If unset, takes either
the source as a parameter ->_emkit("welcome") or will use the
currently defined source as set with ->source("welcome") if
available.

B<WARNING:> Should the kit not exist, this method will die.

Returns Email::MIME::Kit object (and stores it for later use)

=cut

sub _emkit {
    my $self = shift;

    if ($self->{ _emkit }) {
        return $self->{ _emkit };
    }

    my $source = shift || $self->source;
    my $tpath = $self->{ _template_path } || ".";

    die "Cannot create EMKit without a source" unless ($source);

    $self->{ _emkit } = Email::MIME::Kit->new({
        source => "$tpath/$source"
    });

    # If the source kit doesn't exist, the following code will never
    # be run as Email::MIME::Kit dies!
    return $self->{ _emkit };
}

=head2 _email()

B<WARNING:> Does not return $self but returns the assembled email object.
Used internally within ->send(). No validation, returns undef if kit
hasn't been assembled.

Returns Email::MIME object.

=cut

sub _email {
    my $self = shift;
    die "Email kit not yet assembled" unless $self->{ _email };
    return $self->{ _email };
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
