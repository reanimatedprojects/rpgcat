package RPGCat::Model::Hashids;

use strict;
use warnings;

use base 'Catalyst::Model::Adaptor';

use Hashids;
use Moose;

__PACKAGE__->config( class => "Hashids" );

has 'HashidInstance' => (
    is => 'rw',
    isa => 'Hashids',
);

# Hashids requires a hash, not hashref
sub mangle_arguments {
    my ($self, $args) = @_;
    return %$args;
}

our $AUTOLOAD;

# Any methods requested are passed through to Hashids

sub AUTOLOAD {
    my $self = shift;
    my $name = $AUTOLOAD;
    $name =~ s/.*://;
    $self->HashidInstance->$name(@_);
}

1;
