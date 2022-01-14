#!/bin/bash

echo "This script is obsolete"
echo "Now we support only one flavor, without dependency to Flutter FFmpeg"
exit -1

# ------------------------------------------------------------------------------------------------------

# This script is used to switch from the Flutter Sound FULL flavor to the Flutter Sound LITE flavor
# (or the opposite)

# If the script is called without parameter, it just analyzes the current flavor and print errors if any.

# The allowed parameters are :
# "bin/flavor FULL"  to switch to the full version
# "bin/flavor LITE"  to switch to the lite version.

# If the script encounters errors before doing the switch
# then it does not modify any files.
# If you want to force the changes, add a second script parameter 'force'

# The "Current Directory" must be the Flutter Sound root directory.
# Note : this script uses the GNU-sed ("brew install gnu-sed" on Macos)

# ------------------------------------------------------------------------------------------------------

# Verify the Current Directory.

if [ ! -f "bin/flavor.sh" ]
then
	echo "This script must be called from Flutter Sound root directory"
	exit -1
fi


# ------------------------------------------------------------------------------------------------------

# Processing dart files
# ---------------------

process_dart_file()
{
	if [ $2 == 'FULL' ]; then
		gsed -i "s/^ *import *'package:tau_sound_lite\//import 'package:tau_sound\//" $1
	else
		gsed -i "s/^ *import *'package:tau_sound\//import 'package:tau_sound_lite\//" $1
	fi
}

# ------------------------------------------------------------------------------------------------------


case $1 in
FULL)

  cd tau_sound
		gsed -i  's/^#  flutter_ffmpeg/  flutter_ffmpeg/' 									pubspec.yaml
		gsed -i  's/^#  flutter_ffmpeg/  flutter_ffmpeg/' 									example/pubspec.yaml
		gsed -i  's/^const bool _hasFFmpeg = false;$/const bool _hasFFmpeg = true;/' 						lib/public/util/tau_helper.dart
		gsed -i  "s/^import 'dummy_ffmpeg.dart';$/import 'package:flutter_ffmpeg\/flutter_ffmpeg.dart';/" 			lib/public/util/tau_helper.dart

		gsed -i  's/^name: tau_sound_lite$/name: tau_sound/' pubspec.yaml
		gsed -i  's/^\( *\)tau_sound_lite:/\1tau_sound:/' example/pubspec.yaml

		mv ios/tau_sound_lite.podspec 	ios/tau_sound.podspec 2>/dev/null
# ---
		gsed -i  "s/^ *s.name *=* 'tau_sound_lite'$/s.name = 'tau_sound'/"  							ios/tau_sound.podspec 2>/dev/null
                gsed -i  "s/^ *# *s.dependency *'mobile-ffmpeg-/  s.dependency 'mobile-ffmpeg-/"   					ios/tau_sound.podspec 2>/dev/null
# ---

		gsed -i  "s/^ *#define *[A-Z]*_FLAVOR/#define FULL_FLAVOR/"   								ios/Classes/TauSound.h
                gsed -i  "s/^ *#define *[A-Z]*_FLAVOR/#define FULL_FLAVOR/"   								ios/Classes/FlutterSoundFFmpeg.h

                for f in $(find . -name '*.dart' ); do process_dart_file $f FULL $f; done

		gsed -i  "/ext.flutterFFmpegPackage *= *'audio'$/d"   									android/build.gradle
		gsed -i "1iext.flutterFFmpegPackage = 'audio'" 										android/build.gradle

 		gsed -i  "s/^[ $'\t']*public static *final *boolean *FULL_FLAVOR *= *false;$/    public static final boolean FULL_FLAVOR = true;/"  	android/src/main/java/xyz/canardoux/tausound/TauSound.java
		gsed -i  "s/^[ $'\t']*if *( *FULL_FLAVOR *) *;\/\/\ *{/        if (FULL_FLAVOR) \{/"  							android/src/main/java/xyz/canardoux/tausound/TauSound.java

  cd ..
	;;

# ------------------------------------------------------------------------------------------------------

LITE)
  cd tau_sound
		gsed -i  's/^  flutter_ffmpeg/#  flutter_ffmpeg/' 								pubspec.yaml
		gsed -i  's/^  flutter_ffmpeg/#  flutter_ffmpeg/' 								example/pubspec.yaml
		gsed -i  's/^const bool _hasFFmpeg = true;$/const bool _hasFFmpeg = false;/'  					lib/public/util/tau_helper.dart
		gsed -i  "s/^import 'package:flutter_ffmpeg\/flutter_ffmpeg.dart';$/import 'dummy_ffmpeg.dart';/" 		lib/public/util/tau_helper.dart

		gsed -i  's/^name: tau_sound$/name: tau_sound_lite/' 								pubspec.yaml
		gsed -i  's/^\( *\)tau_sound:/\1tau_sound_lite:/' 								example/pubspec.yaml

		mv ios/tau_sound.podspec ios/tau_sound_lite.podspec 2>/dev/null
# ---
		gsed -i  "s/^ *s.name *=* 'tau_sound'$/s.name = 'tau_sound_lite'/"  						ios/tau_sound_lite.podspec 2>/dev/null
                gsed -i  "s/^ *#* s.dependency *'mobile-ffmpeg-/  # s.dependency 'mobile-ffmpeg-/"   				ios/tau_sound_lite.podspec 2>/dev/null
# ---

                gsed -i  "s/^ *#define *[A-Z]*_FLAVOR/#define LITE_FLAVOR/"   							ios/Classes/TauSound.h
                gsed -i  "s/^ *#define *[A-Z]*_FLAVOR/#define LITE_FLAVOR/"   							ios/Classes/FlutterSoundFFmpeg.h

                for f in $(find . -name '*.dart' ); do process_dart_file $f LITE $f; done

		gsed -i  "/ext.flutterFFmpegPackage *= *'audio'$/d"   								android/build.gradle
		gsed -i "1i//ext.flutterFFmpegPackage = 'audio'" 								android/build.gradle

		gsed -i  "s/^[ $'\t']*public static *final *boolean *FULL_FLAVOR *= *true;$/    public static final boolean FULL_FLAVOR = false;/"  	android/src/main/java/xyz/canardoux/tausound/TauSound.java
		gsed -i  "s/^[ $'\t']*if *( *FULL_FLAVOR *) *{/        if (FULL_FLAVOR) ;\/\/\{/"  							android/src/main/java/xyz/canardoux/tausound/TauSound.java
  cd ..
	;;

# ------------------------------------------------------------------------------------------------------

*)
	echo "Corect syntax is $0 [FULL||LITE]  [force]"
	exit -1
esac

rm -rf tau_sound/example/ios/DerivedData 2>/dev/null
#rm -rf tau_sound/example/ios/Podfile 2>/dev/null

exit 0

