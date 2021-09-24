#!/bin/bash
if [ -z "$1" ]; then
        echo "Correct usage is $0 <Version>"
        exit -1
fi



VERSION=$1
VERSION_CODE=${VERSION//./}
VERSION_CODE=${VERSION_CODE//+/}


gsed -i  "s/^\( *s.version *= *\).*$/\1'$VERSION'/"                                     tau_native/tau_native.podspec
gsed -i  "s/^\( *s.version *= *\).*$/\1'$VERSION'/"                                     tau_sound/ios/tau_sound.podspec 2>/dev/null
gsed -i  "s/^\( *s.version *= *\).*$/\1'$VERSION'/"                                     tau_sound/ios/tau_sound.podspec 2>/dev/null
gsed -i  "s/^\( *s.dependency *'tau_native', *\).*$/\1'$VERSION'/"                      tau_sound/ios/tau_sound.podspec 2>/dev/null
gsed -i  "s/^\( *s.dependency *'tau_native', *\).*$/\1'$VERSION'/"                      tau_sound/ios/tau_sound.podspec 2>/dev/null


gsed -i  "s/^\( *versionName *\).*$/\1'$VERSION'/"                                      tau_native/android/build.gradle
gsed -i  "s/^\( *\/* *implementation 'com.github.canardoux:tau10:\).*$/\1$VERSION'/"    flutter_sound/android/build.gradle

gsed -i  "s/^\( *version: *\).*$/\1$VERSION/"                                           tau_sound/pubspec.yaml
gsed -i  "s/^\( *tau_platform_interface: *#* *\).*$/\1$VERSION/"                        tau_sound/pubspec.yaml
gsed -i  "s/^\( *tau_web: *#* *\).*$/\1$VERSION/"                                       tau_sound/pubspec.yaml

gsed -i  "s/^\( *version: *\).*$/\1$VERSION/"                                           tau_sound/example/pubspec.yaml
gsed -i  "s/^\( *tau_sound: *#* *\^*\).*$/\1$VERSION/"                                  tau_sound/example/pubspec.yaml
gsed -i  "s/^\( *tau_sound: *#* *\^*\).*$/\1$VERSION/"                                  tau_sound/example/pubspec.yaml
gsed -i  "s/^\( *#* *tau_platform_interface: *#* *\^*\).*$/\1$VERSION/"                 tau_sound/example/pubspec.yaml
gsed -i  "s/^\( *#* *tau_web: *#* *\^*\).*$/\1$VERSION/"                                tau_sound/example/pubspec.yaml

gsed -i  "s/^\( *libraryVersion = \).*$/\1$VERSION/"                                    tau_native/android/gradle.properties
gsed -i  "s/^\( *## \).*$/\1$VERSION/"                                                  tau_sound/CHANGELOG.md
gsed -i  "s/^\( *## \).*$/\1$VERSION/"                                                  tau_native/CHANGELOG.md
gsed -i  "s/^\( *## \).*$/\1$VERSION/"                                                  tau_platform_interface/CHANGELOG.md
gsed -i  "s/^\( *## \).*$/\1$VERSION/"                                                  tau_web/CHANGELOG.md

gsed -i  "s/^\( *version: *\).*$/\1$VERSION/"                                           tau_platform_interface/pubspec.yaml

gsed -i  "s/^\( *version: *\).*$/\1$VERSION/"                                           tau_web/pubspec.yaml
gsed -i  "s/^\( *tau_platform_interface: *#* *\).*$/\1$VERSION/"                        tau_web/pubspec.yaml

gsed -i  "s/^\( *\"version\": *\).*$/\1\"$VERSION\",/"                                  tau_web/package.json
gsed -i  "s/^\( *s\.version *= *\).*$/\1'$VERSION'/"                                    tau_web/ios/tau_web.podspec

gsed -i  "s/^tau_version:.*/tau_version: $VERSION/"                                     doc/_config.yml
gsed -i  "s/^\( *version: \).*/\1$VERSION/"                                             doc/_data/sidebars/mydoc_sidebar.yml