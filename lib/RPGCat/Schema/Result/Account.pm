use utf8;
package RPGCat::Schema::Result::Account;

=head1 NAME

RPGCat::Schema::Result::Account

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::PassphraseColumn>

=back

=cut

__PACKAGE__->load_components(
    "InflateColumn::DateTime", "TimeStamp", "PassphraseColumn"
);

=head1 TABLE: C<accounts>

=cut

__PACKAGE__->table("accounts");

=head1 ACCESSORS

=head2 account_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 email

  data_type: 'char'
  is_nullable: 0
  size: 128

=head2 password

  data_type: 'text'
  is_nullable: 1

=head2 date_signup

  data_type: 'datetime'
  is_nullable: 0
  set_on_create: 1
  set_on_update: 0
  datetime_undef_if_invalid: 1

=head2 date_verified

  data_type: 'datetime'
  is_nullable: 1
  default_value: undef
  set_on_create: 0
  set_on_update: 0
  datetime_undef_if_invalid: 1

=head2 date_verified

  data_type: 'datetime'
  is_nullable: 0
  default_value: 0
  datetime_undef_if_invalid: 1

=cut

__PACKAGE__->add_columns(
    "account_id" => {
        data_type => "integer",
        extra => { unsigned => 1 },
        is_auto_increment => 1,
        is_nullable => 0,
    },
    # Anyone with an email address longer than 128 characters will have problems
    "email" => {
        data_type => "char",
        is_nullable => 0,
        size => 128
    },
    # Have the 'password' column use a SHA-1 hash and 20-byte salt
    # with RFC 2307 encoding; Generate the 'check_password" method
    'password' => {
        data_type           => 'text',
        is_nullable         => 1,
        passphrase          => 'rfc2307',
        passphrase_class    => 'SaltedDigest',
        passphrase_args     => {
            algorithm => 'SHA-1',
            salt_random => 20,
        },
        passphrase_check_method => 'check_password',
    },
    'date_signup' => {
        data_type => "datetime",
        is_nullable => 0,
        set_on_create => 1,
        set_on_update => 0,
        datetime_undef_if_invalid => 1,
    },
    'date_verified' => {
        data_type => "datetime",
        is_nullable => 1,
        default_value => undef,
        set_on_create => 0,
        set_on_update => 0,
        datetime_undef_if_invalid => 1,
    },
    "date_lastlogin" => {
        data_type => "datetime",
        is_nullable => 1,
        default_value => undef,
        set_on_create => 0,
        set_on_update => 0,
        datetime_undef_if_invalid => 1,
    },

    "active" => {
        data_type => "int",
        size => 1,
        is_nullable => 0,
        default_Value => 1,
    },
);

=head1 PRIMARY KEY

=over 4

=item * L</account_id>

=back

=cut

__PACKAGE__->set_primary_key("account_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<email>

=over 4

=item * L</email>

=back

=cut

__PACKAGE__->add_unique_constraint("email", ["email"]);

__PACKAGE__->has_many(
    'account_roles' => 'RPGCat::Schema::Result::AccountRole',
    { 'foreign.account_id' => 'self.account_id' }
);

# $account->account_roles->role
__PACKAGE__->many_to_many(
    'roles' => 'account_roles', 'role'
);

__PACKAGE__->has_many(
    'characters' => 'RPGCat::Schema::Result::Character',
    { 'foreign.account_id' => 'self.account_id' }
);

__PACKAGE__->meta->make_immutable;
1;
