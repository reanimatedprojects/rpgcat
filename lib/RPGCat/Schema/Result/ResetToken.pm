package RPGCat::Schema::Result::ResetToken;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

__PACKAGE__->table("reset_tokens");

__PACKAGE__->add_columns(
    "reset_token_id",
    {
        data_type => "integer",
        extra => { unsigned => 1 },
        is_nullable => 0,
        is_auto_increment => 1,
    },
    "token" => {
        data_type => "char",
        size => 64,
        is_nullable => 0
    },
    "date_issued" => {
        data_type => "datetime",
        is_nullable => 0,
        set_on_create => 1
    },
    "client_ip" => {
        data_type => "char",
        size => 45,
        is_nullable => 1
    },
    "account_id" => {
        data_type => "integer",
        extra => { unsigned => 1 }
    },
    "email" => {
        data_type => "char",
        size => 255,
        is_nullable => 0
    },
);

__PACKAGE__->set_primary_key("reset_token_id");

__PACKAGE__->add_unique_constraint( ['token'] );

__PACKAGE__->belongs_to(
    account => 'RPGCat::Schema::Result::Account',
    { 'foreign.account_id' => 'self.account_id' },
    { on_delete => undef, on_update => undef }
);

__PACKAGE__->meta->make_immutable;
1;
