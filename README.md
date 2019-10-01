# rpgcat
Catalyst based RPG framework

## About

The aim of this application is to serve as a fairly functional base to
design your own Browser based RPG. It probably won't be fancy but we
hope there is enough to get a basic game up and running quite fast. The
actual content (the map for example) is left for you to provide!

## Installation

This works best if you install a local version of Perl and all associated modules. This can be done using Perl::Build in one of the ways described at https://metacpan.org/pod/Perl::Build

If you already have a working cpanm and can install Perl::Build as a system Perl module, opt for the CLI interface. Alternatively (and this would be the recommended way), use the CLI interface without dependencies method.

We have included a script in this repository which will do all the hard work for you. It could take a while to build Perl and all the required modules - it's also configured for Perl 5.24.1 - if you would like a more recent version, please edit the script and change the variable PERLVERSION

    sh build-perl-5.24.1.sh
    cpanm Catalyst::Devel

This next command should output 1.39 (or something more recent)

    perl -MCatalyst::Devel -e 'print "$Catalyst::Devel::VERSION\n";'

In GitHub, fork the main reanimatedprojects/rpgcat repository into your personal repository and clone your repository and install any extra Perl dependencies.

    cd ~
    git clone git@github.com:YOURUSER/rpgcat.git
    cd ~/rpgcat
    cpanm --installdeps .

To keep your version in sync with the main repository, configure the
upstream repository

    git remote add upstream https://github.com/reanimatedprojects/rpgcat.git

and merge in changes from upstream/master. Full instructions can be
found at https://help.github.com/articles/syncing-a-fork/

    git fetch upstream
    git merge upstream/master

## Running

To run the application for development purposes, use the following command:

    script/rpgcat_server.pl -r -d --fork

If you don't use --fork, it'll only run a single thread which will cause
simultaneous requests to hang until the previous request has finished.

-r causes the server to monitor Perl modules and automatically reload if
there are any changes detected.

-d enables debug output which includes timings, headers, etc.

Hopefully your final application will work on PaaS such as Heroku and Flynn
without too many changes required.

## Licensing

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

