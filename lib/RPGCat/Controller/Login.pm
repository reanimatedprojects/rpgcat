package RPGCat::Controller::Login;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

RPGCat::Controller::Login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

This is the main login page

=cut

sub login_index :Path("/login") Args(0) {
    my ( $self, $c ) = @_;

    my $email = $c->request->params->{ 'email' };
    my $password = $c->request->params->{ 'password' };

    if ($email && $password) {

        # Default location after login
        $c->response->redirect("/account");

        # Attempt to log the user in
        if ($c->authenticate({
                email => $email,
                password => $password
            })) {

            # Prevents session fixation exploit
            $c->change_session_id;

            my $ral = $c->flash->{ redirect_after_login };
            if ($ral) {
                $c->response->redirect($ral);
            }
        } else {

            # Set an error
            $c->response->redirect(
                $c->uri_for(
                    $c->controller('Login')->action_for('login_index'), {
                        mid => $c->set_error_msg("Bad email or password")
                    }
                )
            );
            $c->detach();
        }
    }

    $c->stash(
        template => "login.html"
    );
}

=head2 logout

Logout the current account

=cut

sub logout :Path('/logout') :Args(0) {
    my ( $self, $c ) = @_;

    # Log the user out
    $c->logout;

    # Send the user to the starting point
    $c->response->redirect($c->uri_for('/'));
}

=head2 signup

The signup page for new accounts.

=cut

sub signup :Path("/signup") Args(0) {
    my ($self, $c) = @_;

    $c->stash( template => "signup.html" );
    unless ($c->request->method =~ /^POST$/i) {
        $c->detach();
    }

    my $email = $c->request->params->{ 'email' };
    my $password = $c->request->params->{ 'password' };

    # Process to follow...

    # Enter an email and password. Account is created. "Verification
    # email has been sent to $email" is shown. User redirected to login page.

    # If the account already existed, they'll more than likely have the
    # wrong password when they try to login - at that point the legit
    # user with that email will have received something like "We
    # received a request for a new account with this email. You already
    # have an account so the new account was NOT created. If you have
    # forgotten your password, you can <reset it>."

    # If the account didn't exist, the email says "We received a request
    # for a new account with this email. If this was requested by yourself,
    # <confirm your email>. If it was not requested by you, <deactivate
    # the account>"

    my $account = eval {
        $c->model('DB::Account')->create({
            email => $email,
            password => $password,
        });
    };
    if ($@ || (! defined $account)) {

        # An account most likely already exists with this email address

        # FIXME: At this point, we could re-populate the form, but since
        # we don't want to provide their password in the page source, and
        # the email they picked already has an account, there's not a lot
        # of point!

        # FIXME: Send email to $email
        my $exists = eval {
            $c->model('DB::Account')->search({ email => $email });
        };
        if ($@ || ! defined $exists) {
            # Something went seriously wrong, we should tell the user.
            $c->log->debug("Couldn't create account for $email, but couldn't find one either");

            $c->response->redirect(
                $c->uri_for("/login", {
                    mid => $c->set_error_msg(
                        "An error occurred creating your account."
                    )
                })
            );
            $c->detach();

        } else {
            my $account = $exists->single();

            my $emkit = $c->model('EMKit', transport_class => 'Email::Sender::Transport::Sendmail')
                ->template("verification-exists.mkit", {
                    destination_email => $account->email,
                    account => $account,
                    config_url  => $c->uri_for('/'),
                    config_name => $c->config->{ name },
                    email => $account->email,
                })
                ->to( $account->email );

            #$c->log->debug("Email:\n" . $emkit->_email->as_string );
            $emkit->send();
        }
    } else {

        # FIXME: Send verification email to $email asking user to confirm
        # their email address (note - this does not log them in!)

        my $emkit = $c->model('EMKit', transport_class => 'Email::Sender::Transport::Sendmail')
            ->template("verification-new.mkit", {
                destination_email => $email,
                account => undef,
                config_url  => $c->uri_for('/'),
                config_name => $c->config->{ name },

                email => $account->email,
            })
            ->to( $account->email );

        #$c->log->debug("Email:\n" . $emkit->_email->as_string );
        $emkit->send();
    }

    # Now we redirect to the login page. If it was a new account, they'll
    # know the password and it'll allow them to confirm that they know what
    # it is (and maybe auto-store in password manager)
    # If it was an attempt to create a duplicate, then chances are they
    # won't know the password and will then get the option to recover the
    # password through the normal route.

    $c->response->redirect(
        $c->uri_for("/login", {
            mid => $c->set_success_msg(
                "A confirmation email has been sent."
            )
        })
    );
}

=head2 forgot

This page allows a user to request a password reset link.

=cut

sub forgot :Path("/forgot") Args(0) {
    my ($self, $c) = @_;

    $c->stash( template => "forgot.html" );
    my $email = $c->request->params->{ 'email' };

    # Not a form submission, just the GET so show the form.
    unless ($email) { $c->detach(); }

    # Message to tell the user we're doing something.
    my $success_msg = "An email is being sent with instructions.";

    # Find the account by email address
    my $account = eval {
        $c->model('DB::Account')->search({ email => $email })->single();
    };
    if ($@ || ! defined $account) {
        # Something went wrong, or we didn't find the user account
# {{{
        $c->log->debug("No user found for $email");

        my $emkit = $c->model('EMKit',
                transport_class => 'Email::Sender::Transport::Sendmail');
        $emkit = $emkit->template("forgotten-notexists.mkit", {
                destination_email => $email,
                account => undef,
                config_url  => $c->uri_for('/'),
                config_name => $c->config->{ name },
            })
            ->to( $email );
        $emkit->send();

        # Redirect to login page, reload won't (pretend to) send another email
        $c->response->redirect(
            $c->uri_for("/login", {
                mid => $c->set_status_msg($success_msg)
            })
        );
        $c->detach();
# }}}
    } elsif (! $account->active) {
        # Check for active status - suspended account
# {{{
        my $emkit = $c->model('EMKit',
                transport_class => 'Email::Sender::Transport::Sendmail');
        $emkit = $emkit->template("forgotten-suspended.mkit", {
                destination_email => $email,
                account => $account,
                config_url => $c->uri_for('/'),
                config_name => $c->config->{ name },
            })
            ->to($email);
        $emkit->send();

        # Redirect to login page, reload won't send another email
        $c->response->redirect(
            $c->uri_for("/login", {
                mid => $c->set_status_msg($success_msg)
            })
        );
        $c->detach();
# }}}
    }

    # Active account - generate token and mail the user
# {{{
    my $tokens_rs = $c->model('DB::ResetToken');

    # When creating a reset token, all others for this account
    # should be invalidated.
    $tokens_rs->search({ account_id => $account->account_id })->delete();

    my $token = $tokens_rs->create({
        client_ip => $c->request->address,
        account_id => $account->account_id,
        email => $account->email,
    });

    my $token_value = Digest::SHA::sha256_hex(
        $token->date_issued,
        $token->client_ip,
        $token->account_id,
        $token->email,
        # Include the account password hash so changing the password
        # invalidates all previous tokens
        $account->password,
    );
    # Store the hashed token in the db.
    $token->token($token_value);
    $token->update();

    my $hashid = $c->model('Hashids')->encode( $token->reset_token_id );
    my $reset_link = $c->uri_for("/reset", {
        t => $token_value, i => $hashid
    });

    $c->log->debug("User found " . $account->account_id . " token $token_value id $hashid");
    my $emkit = $c->model('EMKit',
            transport_class => 'Email::Sender::Transport::Sendmail')
        ->template("forgotten-exists.mkit", {
            destination_email => $account->email,
            account => $account,
            config_url  => $c->uri_for('/'),
            config_name => $c->config->{ name },
            reset_url => $reset_link,
        })
        ->to( $account->email );
    $emkit->send();

    # Redirect to login page, reload won't send another email
    $c->response->redirect(
        $c->uri_for("/login", {
            mid => $c->set_status_msg($success_msg)
        })
    );
    $c->detach();
# }}}
}

=head2 reset

This is the password reset page, requires t=$token and i=$id as params

=cut

sub reset :Path("/reset") Args(0) {
    my ($self, $c) = @_;
    $c->stash( template => "reset.html" );

    my $params = $c->request->params;
    unless (exists $params->{ t } && exists $params->{ i }) {
        # If there is no token or id parameter, just show the page which
        # asks for the user to enter the values.

        # FIXME: We should probably display them separately in the email
        # FIXME: as well as just in the link.

        $c->stash( params => $params );
        $c->detach();
    }

}


=encoding utf8

=head1 AUTHOR

Simon Amor <simon@leaky.org>

=head1 LICENSE

This program is free software; but please see the LICENSING file for
more information.

=cut

__PACKAGE__->meta->make_immutable;

1;
