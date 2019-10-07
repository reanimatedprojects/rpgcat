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
    if ($@ || (! defined $account) || $account->account_id == 0) {

        $c->log->debug("account create error: $@");

        # An account most likely already exists with this email address

        # FIXME: At this point, we could re-populate the form, but since
        # we don't want to provide their password in the page source, and
        # the email they picked already has an account, there's not a lot
        # of point!

        # FIXME: Send email to $email
        my $exists = eval {
            $c->model('DB::Account')->search({ email => $email });
        };
        if ($@ || ! defined $exists || $exists->count == 0) {
            # Something went seriously wrong, we should tell the user.
            $c->log->debug("Couldn't create account for $email, but couldn't find one either: $@");

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
            # In theory account shouldn't be empty otherwise
            # the if () would have caught it via $exists->count == 0
            # Perhaps worth adding some more checks here just in case?

            my $emkit = $c->model('EMKit')
                ->template("verification-exists.mkit", {
                    destination_email => $account->email,
                    account => $account,
                    config_url  => $c->uri_for('/'),
                    config_name => $c->config->{ name },
                    email => $account->email,
                })
                ->to( $account->email );

            #$c->log->debug("Email:\n" . $emkit->_email->as_string );
            my $res = $emkit->send();
            unless ($res) {
                $c->log->debug("Failed to send email " . __FILE__ . ": " . __LINE__ . " --- " . $emkit->error()) if ($c->debug);
            }
        }
    } else {

        # FIXME: Send verification email to $email asking user to confirm
        # their email address (note - this does not log them in!)

        my $emkit = $c->model('EMKit')
            ->template("verification-new.mkit", {
                destination_email => $email,
                account => undef,
                config_url  => $c->uri_for('/'),
                config_name => $c->config->{ name },

                email => $account->email,
            })
            ->to( $account->email );

        #$c->log->debug("Email:\n" . $emkit->_email->as_string );
        my $res = $emkit->send();
        unless ($res) {
            $c->log->debug("Failed to send email " . __FILE__ . ": " . __LINE__ . " --- " . $emkit->error()) if ($c->debug);
        }
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

        my $emkit = $c->model('EMKit')
            ->template("forgotten-notexists.mkit", {
                destination_email => $email,
                account => undef,
                config_url  => $c->uri_for('/'),
                config_name => $c->config->{ name },
            })
            ->to( $email );
        my $res = $emkit->send();
        unless ($res) {
            $c->log->debug("Failed to send email " . __FILE__ . ": " . __LINE__ . " --- " . $emkit->error()) if ($c->debug);
        }

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
        my $emkit = $c->model('EMKit')
            ->template("forgotten-suspended.mkit", {
                destination_email => $email,
                account => $account,
                config_url => $c->uri_for('/'),
                config_name => $c->config->{ name },
            })
            ->to($email);
        my $res = $emkit->send();
        unless ($res) {
            $c->log->debug("Failed to send email " . __FILE__ . ": " . __LINE__ . " --- " . $emkit->error()) if ($c->debug);
        }

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


    my $hash_this = join "", $token->date_issued->iso8601, $token->client_ip, $token->account_id, $token->email, $account->password->as_rfc2307;
    $c->log->debug("Hash: $hash_this");

    my $token_value = Digest::SHA::sha256_hex(
        $token->date_issued->iso8601,
        $token->client_ip,
        $token->account_id,
        $token->email,
        # Include the account password hash so changing the password
        # invalidates all previous tokens
        $account->password->as_rfc2307,
    );

    # Store the hashed token in the db.
    $token->token($token_value);
    $token->update();

    my $hashid = $c->model('Hashids')->encode( $token->reset_token_id );
    my $reset_link = $c->uri_for("/reset", {
        t => $token_value, i => $hashid
    });

    $c->log->debug("User found " . $account->account_id . " token $token_value id $hashid");
    my $emkit = $c->model('EMKit')
        ->template("forgotten-exists.mkit", {
            destination_email => $account->email,
            account => $account,
            config_url  => $c->uri_for('/'),
            config_name => $c->config->{ name },
            reset_url => $reset_link,
        })
        ->to( $account->email );
    my $res = $emkit->send();
    unless ($res) {
        $c->log->debug("Failed to send email " . __FILE__ . ": " . __LINE__ . " --- " . $emkit->error()) if ($c->debug);
    }

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
    my $reset_id = $c->model('Hashids')->decode( $params->{ i } || "");
    my $hash = $params->{ t } || "";

    my $error_msg = "Recovery token expired, invalid or not found.";

    # If there is no token or id parameter, redirect to forgot page
    unless ($reset_id && $hash) {
        $c->log->debug("No reset id ($reset_id)  or hash ($hash)") if $c->debug;
        $c->response->redirect(
            $c->uri_for("/forgot", {
                mid => $c->set_error_msg($error_msg),
            })
        );
        $c->detach();
    }

    my $token = $c->model('DB::ResetToken')->find( $reset_id );
    # Token wasn't found.
    unless ($token) {
        $c->log->debug("No token found for reset id $reset_id") if $c->debug;
        $c->response->redirect(
            $c->uri_for("/forgot", {
                mid => $c->set_error_msg($error_msg),
            })
        );
        $c->detach();
    }

    my $hash_this = join "", $token->date_issued->iso8601, $token->client_ip, $token->account_id, $token->email, $token->account->password->as_rfc2307;
    $c->log->debug("Hash: $hash_this");
    my $token_value = Digest::SHA::sha256_hex(
        $token->date_issued->iso8601,
        $token->client_ip,
        $token->account_id,
        $token->email,
        $token->account->password->as_rfc2307,
    );

    # Hash didn't match - the values above should be the
    # same as the ones in the forgotten password page.
    unless ($hash eq $token_value) {
        $c->log->debug("Hash mismatch with $token_value") if $c->debug;
        $c->response->redirect(
            $c->uri_for("/forgot", {
                mid => $c->set_error_msg($error_msg),
            })
        );
        $c->detach();
    }

    # Token expired, was issued more than 48h ago
    if ($token->date_issued->epoch < time() - 86400*2) {
        $c->log->debug("Expired, issued: " . $token->date_issued) if $c->debug;
        $token->delete();
        $c->response->redirect(
            $c->uri_for("/forgot", {
                mid => $c->set_error_msg($error_msg),
            })
        );
        $c->detach();
    }

    # the 'x' parameter deletes the token instantly.
    if (exists $params->{ x } && $params->{ x }) {
        $token->delete();
        $c->response->redirect(
            $c->uri_for("/login", {
                mid => $c->set_status_msg("Password reset process cancelled."),
            })
        );
        $c->detach();
    }

    ## Store the user in the stash
    my $account = $token->account;
    $c->stash(
        account => $account,
        params => {
            i => $c->model('Hashids')->encode( $reset_id ),
            t => $hash,
        }
    );

    # Prompt for new password if not provided
    unless ($params->{ new_password } && $params->{ new_password2 }) {
        $c->log->debug("Need a new password") if $c->debug;
        $c->detach();
    }

    # Passwords don't match
    if ($params->{ new_password } ne $params->{ new_password2 }) {
        $c->response->redirect(
            $c->uri_for("/reset", {
                t => $params->{ t },
                i => $params->{ i },
                mid => $c->set_error_msg("New passwords do not match")
            })
        );
        $c->detach();
    }

    # Suspended account - don't allow the reset
    # This will only be triggered if the account was disabled between
    # requesting the password link and using it.
    unless ($account->active) {
        $c->response->redirect(
            $c->uri_for("/login", {
                mid => $c->set_status_msg("Account suspended - please contact us"),
            })
        );
        $c->detach();
    }

    $account->password( $params->{ new_password } );
    # Always use UTC - it saves a lot of confusion
    $account->date_last_password_change( $account->result_source->resultset->utc_now );
    $account->update();

    # FIXME: Best Practice: We should send a notification that the password has been reset.

    $token->delete();

    $c->response->redirect(
        $c->uri_for("/login", {
            mid => $c->set_success_msg( "Password changed" ),
        })
    );
    $c->detach();
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
