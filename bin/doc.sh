#!/bin/bash

VERSION=$1

rm -r doc/pages/tau-sound/api 2>/dev/null
if [ ! -z "$VERSION" ]; then
        echo "Setting the tau version"
        gsed -i  "s/^tau_version:.*/tau_version: $VERSION/"                                     doc/_config.yml
        gsed -i  "s/^\( *version: \).*/\1$VERSION/"                                             doc/_data/sidebars/mydoc_sidebar.yml
fi

rm -rf tau_sound/example/build tau_sound/build doc/_site 
# tau_web
# -------

cd tau_sound/example
flutter build web
cd ../..

#cp privacy_policy.html doc/_site

echo "Upload"
tar czf _toto3.tgz tau_sound tau_web tau_platform_interface
cd doc
tar czf ../_toto.tgz *
cd ..
scp bin/doc2.sh canardoux@canardoux.xyz:/var/www/vhosts/canardoux.xyz/bin
scp _toto.tgz canardoux@canardoux.xyz:/var/www/vhosts/canardoux.xyz/
scp _toto3.tgz canardoux@canardoux.xyz:/var/www/vhosts/canardoux.xyz/
ssh -p7822 canardoux@canardoux.xyz "bash /var/www/vhosts/canardoux.xyz/bin/doc2.sh"
rm _toto.tgz _toto2.tgz _toto3.tgz 2>/dev/null

echo 'E.O.J'