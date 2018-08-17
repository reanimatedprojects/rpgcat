package RPGCat::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=encoding utf-8

=head1 NAME

RPGCat::Controller::Root - Root Controller for RPGCat

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub root_index_index :Path('/index') :Args(0) {
    my ($self, $c) = @_;
    $c->response->redirect( $c->uri_for("/") );
}

sub root_index :Path('/') :Args(0) {
    my ( $self, $c ) = @_;

    my $counter = ++ $c->session->{ counter };

    $c->stash( counter => $counter );
    $c->stash( template => "index.html" );
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

sub auto :Private {
    my ($self, $c) = @_;

    # The final page config is added to the stash so that the page
    # can display menus etc correctly in the wrapper.
    my $page_config_href = mkpage($c->request->path);

    $c->stash(
        fn_mkpage => \&mkpage,
        page_config => $page_config_href,
    );

    # Load the status messages into the stash
    $c->load_status_msgs;

    # If authenticated, don't cache any page content!
    $c->response->header('Cache-Control' => 'no-cache') if ($c->user_exists);

    return 1;
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

sub mkpage :Private {
    my $path_to_process = shift;

    my $pages = RPGCat->config->{ RPGCat }{ pages };

    $path_to_process =~ s#^/##;
    my @parts = split '/', $path_to_process;

    # Iterate through the path parts loading the least specific first,
    # gradually adding more specific values (which overwrite less-
    # specific values)
    my %page_config = (
        href => "/$path_to_process",
    );
    my $path = "";
    # This should always exist unless someone removed all the defaults.
    if (exists $pages->{ "/" }) {
        $page_config{$_} = $pages->{ "/" }{ $_ } foreach (keys %{$pages->{ "/" }});
    }
    foreach my $p (@parts) {
        $path .= "/$p";
        next unless (exists $pages->{ $path });
        foreach my $k (keys %{$pages->{ $path }}) {
            $page_config{$k} = $pages->{ $path }{ $k };
        }
    }
    return \%page_config;
}


=head1 AUTHOR

Simon Amor <simon@leaky.org>

=head1 LICENSE

This program is free software; but please see the LICENSING file for
more information.

=cut

__PACKAGE__->meta->make_immutable;

1;
