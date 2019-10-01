#!/usr/bin/env bash

LOCALDIR=${HOME}/local/
PERLVERSION=5.24.1
PERLINSTALLTARGETDIR=${LOCALDIR}perl-${PERLVERSION}
PERLBUILDURL=https://raw.githubusercontent.com/tokuhirom/Perl-Build/master/perl-build
CPANMURL=http://cpanmin.us/
LOCALPERL=${PERLINSTALLTARGETDIR}/bin/perl${PERLVERSION}
LOCALEXEC=${LOCALDIR}exec
RUNTESTS=--notest
PERLJOBS=9

echo "Installing Perl ${PERLVERSION}"
curl ${PERLBUILDURL} | perl - --jobs ${PERLJOBS} ${RUNTESTS} --noman ${PERLVERSION} ${PERLINSTALLTARGETDIR}

echo "Bootstrapping local::lib"
curl -L ${CPANMURL} | perl - -l ${LOCALDIR} local::lib
eval $(perl -I${LOCALDIR}lib/perl5 -Mlocal::lib=--deactivate-all); \
        curl -L ${CPANMURL} | ${LOCALPERL} - -L ${LOCALDIR} ${RUNTESTS} --reinstall \
        local::lib App::cpanminus App::local::lib::helper

echo "Creating exec program (for cron etc)"
cat > ${LOCALEXEC} <<EOF
#!/usr/bin/env bash
eval \$(perl -I${LOCALDIR}lib/perl5 -Mlocal::lib=--deactivate-all)
source ${LOCALDIR}bin/localenv-bashrc
PATH=${LOCALDIR}bin:${PERLINSTALLTARGETDIR}/bin:\$PATH
export PATH
exec  "\$@"
EOF
chmod 755 ${LOCALEXEC}

# For running commands within the normal shell
cat >> $HOME/.bash_profile <<EOF
eval \$(perl -I${LOCALDIR}lib/perl5 -Mlocal::lib=--deactivate-all)
source ${LOCALDIR}bin/localenv-bashrc
export PATH=${LOCALDIR}bin:${PERLINSTALLTARGETDIR}/bin:\$PATH
EOF
