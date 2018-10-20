#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install 1.02;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'RPGCat';
all_from 'lib/RPGCat.pm';

requires 'Catalyst::Runtime' => '5.90105';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Moose';
requires 'namespace::autoclean';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats

requires 'App::DH';

test_requires 'Test::More' => '0.88';
test_requires 'Test::DBIx::Class';
catalyst;

# For the config
requires 'YAML::XS';

# Template view
requires 'Catalyst::Helper::View::TT';

# Session handling
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::DBI';

requires 'Catalyst::Restarter';

requires 'DBIx::Class::Schema::Loader';
requires 'DBIx::Class::TimeStamp';
requires 'DBIx::Class::PassphraseColumn';
requires 'DBIx::Class::InflateColumn::Serializer';
requires 'Catalyst::Helper::Model::DBIC::Schema';
requires 'MooseX::NonMoose';
requires 'DBD::mysql';
requires 'Digest::SHA256';

requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authorization::Roles';
requires 'Catalyst::Plugin::StatusMessage';
requires 'Catalyst::Authentication::Store::DBIx::Class';

requires 'Catalyst::Model::Factory';
requires 'Email::MIME::Kit';
requires 'Email::Sender::Simple';
requires 'Email::MIME::Kit::Renderer::TT';

requires 'HTML::FormHandler';

requires 'Hashids';

install_script glob('script/*.pl');
auto_install;
WriteAll;
