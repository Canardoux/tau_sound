#!/bin/bash


# Podfile sometimes disapeers !???!
if [ ! -f tau_sound/example/ios/Podfile ]; then
    echo "Podfile not found."
    cp tau_sound/example/ios/Podfile.keep tau_sound/example/ios/Podfile
fi

grep "pod 'tau_core'," tau_sound/example/ios/Podfile > /dev/null
if [ $? -ne 0 ]; then

            echo "Podfile is not patched"
            echo "" >> tau_sound/example/ios/Podfile
            echo "# =====================================================" >> tau_sound/example/ios/Podfile
            echo "# The following instruction is only for Tau debugging." >> tau_sound/example/ios/Podfile
            echo "# Do not insert such a line in a real App." >> tau_sound/example/ios/Podfile
            echo "# pod 'tau_core', :path => '../../../tau_core'"  >> tau_sound/example/ios/Podfile
            echo "# =====================================================" >> tau_sound/example/ios/Podfile
fi


#gsed -i  "s/^#* *platform :ios,.*$/platform :ios, '10.0'/" tau_sound/example/ios/Podfile

if [ "_$1" = "_REL" ] ; then

        gsed -i  "s/^ *implementation project(':tau_core')$/    \/\/ implementation project(':tau_core')/"                                                              tau_sound/example/android/app/build.gradle
        gsed -i  "s/^ *project(':tau_core').projectDir\(.*\)$/\/\/ project(':tau_core').projectDir\1/"                                                                  tau_sound/example/android/settings.gradle
        gsed -i  "s/^ *include 'tau_core'$/\/\/ include 'tau_core'/"                                                                                                    tau_sound/example/android/settings.gradle
        gsed -i  "s/^ *project(':tau_core').projectDir = /\/\/project(':tau_core').projectDir = /"                                                                      tau_sound/android/settings.gradle

        gsed -i  "s/^ *\(implementation project(':tau_core'\)/    \/\/\1/"                                                                                              tau_sound/android/build.gradle
        gsed -i  "s/^ *\/\/ *implementation 'com.github.Canardoux:tau_core:/    implementation 'com.github.Canardoux:tau_core:/"                                        tau_sound/android/build.gradle

        gsed -i  "s/^ *pod 'tau_core',\(.*\)$/# pod 'tau_core',\1/"                                                                                                     tau_sound/example/ios/Podfile

# tau_web/pubspec.yaml
#---------------------
        gsed -i  "s/^ *tau_platform_interface: *#* *\(.*\)$/  tau_platform_interface: \1/"                                                          tau_web/pubspec.yaml
        gsed -i  "s/^ *path: \.\.\/tau_platform_interface # Flutter Sound Dir$/#    path: \.\.\/tau_platform_interface # Flutter Sound Dir/"        tau_web/pubspec.yaml


# tau_sound/pubspec.yaml
#---------------------------
        gsed -i  "s/^ *tau_platform_interface: *#* *\(.*\)$/  tau_platform_interface: \1/"                                                          tau_sound/pubspec.yaml
        gsed -i  "s/^ *path: \.\.\/tau_platform_interface # Flutter Sound Dir$/#    path: \.\.\/tau_platform_interface # Flutter Sound Dir/"        tau_sound/pubspec.yaml

        gsed -i  "s/^ *tau_web: *#* *\(.*\)$/  tau_web: \1/"                                                                                                            tau_sound/pubspec.yaml
        gsed -i  "s/^ *path: \.\.\/tau_web # Flutter Sound Dir$/#    path: \.\.\/tau_web # Flutter Sound Dir/"                                                          tau_sound/pubspec.yaml


# tau_sound/example/pubspec.yaml
#-----------------------------------
        gsed -i  "s/^ *tau_sound: *#* *\(.*\)$/  tau_sound: \1/"                                                                                                tau_sound/example/pubspec.yaml
        gsed -i  "s/^ *tau_sound_lite: *#* *\(.*\)$/  tau_sound_lite: \1/"                                                                                      tau_sound/example/pubspec.yaml
        gsed -i  "s/^ *path: \.\.\/ # Flutter Sound Dir$/#    path: \.\.\/ # Flutter Sound Dir/"                                                                        tau_sound/example/pubspec.yaml

        gsed -i  "s/^ *#* *tau_platform_interface: *#* *\(.*\)$/#  tau_platform_interface: \1/"                                                     tau_sound/example/pubspec.yaml
        gsed -i  "s/^ *path: \.\.\/\.\.\/tau_platform_interface # tau_platform_interface Dir$/#    path: \.\.\/\.\.\/tau_platform_interface # tau_platform_interface Dir/" tau_sound/example/pubspec.yaml

        gsed -i  "s/^ *#* *tau_web: *#* *\(.*\)$/#  tau_web: \1/"                                                                                                       tau_sound/example/pubspec.yaml
        gsed -i  "s/^ *path: \.\.\/\.\.\/tau_web # tau_web Dir$/#    path: \.\.\/\.\.\/tau_web # tau_web Dir/"                                                          tau_sound/example/pubspec.yaml

        exit 0

#========================================================================================================================================================================================================


elif [ "_$1" = "_DEV" ]; then

        gsed -i  "s/^ *\/\/ implementation project(':tau_core')$/    implementation project(':tau_core')/"                                                              tau_sound/example/android/app/build.gradle
        gsed -i  "s/^ *\/\/ *project(':tau_core').projectDir\(.*\)$/   project(':tau_core').projectDir\1/"                                                              tau_sound/example/android/settings.gradle
        gsed -i  "s/^ *\/\/ *include 'tau_core'$/   include 'tau_core'/"                                                                                                tau_sound/example/android/settings.gradle
        gsed -i  "s/^ *\/\/ *project(':tau_core').projectDir = /    project(':tau_core').projectDir = /"                                                                tau_sound/android/settings.gradle

        #gsed -i  "s/^\( *implementation [^\/]*\/\/ Tau Core\)$/\/\/\1/"                                                                                                 tau_sound/android/build.gradle
        gsed -i  "s/^ *\/\/ *\(implementation project(':tau_core'\)/    \1/"                                                                                            tau_sound/android/build.gradle
        gsed -i  "s/^ *implementation 'xyz.canardoux:tau_core:/    \/\/implementation 'xyz.canardoux:tau_core:/"                                                        tau_sound/android/build.gradle

        gsed -i  "s/^ *# pod 'tau_core',\(.*\)$/pod 'tau_core',\1/"                                                                                                     tau_sound/example/ios/Podfile


# tau_web/pubspec.yaml
#---------------------
        gsed -i  "s/^ *tau_platform_interface: *#* *\(.*\)$/  tau_platform_interface: # \1/"                                                        tau_web/pubspec.yaml
        gsed -i  "s/^# *path: \.\.\/tau_platform_interface # Flutter Sound Dir$/    path: \.\.\/tau_platform_interface # Flutter Sound Dir/"        tau_web/pubspec.yaml


# tau_sound/pubspec.yaml
#---------------------------
        gsed -i  "s/^ *tau_platform_interface: *#* *\(.*\)$/  tau_platform_interface: # \1/"                                                        tau_sound/pubspec.yaml
        gsed -i  "s/^# *path: \.\.\/tau_platform_interface # Flutter Sound Dir$/    path: \.\.\/tau_platform_interface # Flutter Sound Dir/"        tau_sound/pubspec.yaml

        gsed -i  "s/^ *tau_web: *#* *\(.*\)$/  tau_web: # \1/"                                                                                                          tau_sound/pubspec.yaml
        gsed -i  "s/^# *path: \.\.\/tau_web # Flutter Sound Dir$/    path: \.\.\/tau_web # Flutter Sound Dir/"                                                          tau_sound/pubspec.yaml


# tau_sound/example/pubspec.yaml
#-----------------------------------
        gsed -i  "s/^ *tau_sound: *#* *\(.*\)$/  tau_sound: # \1/"                                                                                              tau_sound/example/pubspec.yaml
        gsed -i  "s/^ *tau_sound_lite: *#* *\(.*\)$/  tau_sound_lite: # \1/"                                                                                    tau_sound/example/pubspec.yaml
        gsed -i  "s/^# *path: \.\.\/ # Flutter Sound Dir$/    path: \.\.\/ # Flutter Sound Dir/"                                                                        tau_sound/example/pubspec.yaml

        gsed -i  "s/^ *#* *tau_platform_interface: *#* *\(.*\)$/  tau_platform_interface: # \1/"                                                    tau_sound/example/pubspec.yaml
        gsed -i  "s/^# *path: \.\.\/\.\.\/tau_platform_interface # tau_platform_interface Dir$/    path: \.\.\/\.\.\/tau_platform_interface # tau_platform_interface Dir/" tau_sound/example/pubspec.yaml

        gsed -i  "s/^ *#* *tau_web: *#* *\(.*\)$/  tau_web: # \1/"                                                                                                      tau_sound/example/pubspec.yaml
        gsed -i  "s/^# *path: \.\.\/\.\.\/tau_web # tau_web Dir$/    path: \.\.\/\.\.\/tau_web # tau_web Dir/"                                                          tau_sound/example/pubspec.yaml

        exit 0

else
        echo "Correct syntax is $0 [REL | DEV]"
        exit -1
fi
echo "Done"
