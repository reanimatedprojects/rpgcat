use utf8;
package RPGCat::Schema::ResultSet::Account;

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

__PACKAGE__->load_components('Helper::ResultSet::DateMethods1');

1;

