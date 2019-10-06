requires 'Catalyst::Runtime' => '5.90105';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Controller::REST';
requires 'Catalyst::Action::RenderView';
requires 'Moose';
requires 'namespace::autoclean';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats

requires 'App::DH';

on 'test' => sub {
    requires 'Test::More' => '0.88';
    requires 'Test::DBIx::Class';
};

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
requires 'DBIx::Class::Helper::ResultSet::DateMethods1';
requires 'Catalyst::Helper::Model::DBIC::Schema';
requires 'MooseX::NonMoose';
requires 'Types::Standard';
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
requires 'Git';

requires 'Hashids';

