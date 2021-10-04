---
title:  "Contributions"
description: "We need you!"
summary: "We need you!"
permalink: tau_dev.html
tags: [contributions]
keywords: Contributions
---

# Contributions

τ Sound is a free and Open Source project. Several contributors have already contributed to τ. Specially :

- @hyochan who is the Flutter Sound father
- @salvatore373 who wrote the Track Player
- @bsutton who wrote the UI Widgets
- @larpoux who add several codec supports

**We really need your contributions.**
Pull Requests are welcome and will be considered very carefully.

## Setup a development environment

### Clone the &tau; project and the tau_native module.

```sh
cd some_where
git clone --recursive https://github.com/Canardoux/tau10.git
```

{% include note.html content="
The project name is temporarily named `tau10`, because the Flutter Sound project already uses the project name `tau`.
Probably in the future, we will change the Flutter Sound name to `flutter_sound`, and we will be able to rename the τ project as `tau`.
" %}

### setup a development environment

cd to the &tau; root dir and run the script `bin/reldev.sh DEV`

```sh
cd tau10
bin/reldev.sh DEV
```

### iOS signing

Open tau/flutter_sound/example/ios/Runner.xcworkspace in XCode, and set your `Team` in the `Signing & Capabilities` tab.

### Set your Flutter Sound flavor

```sh
cd tau

# If you want to work on the full flavor
bin/flavor.sh FULL

# if you want to work on the lite flavor
bin/flavor.sh LITE
```


### Clean your space

Probably good to clean the space :

```sh
cd tau10/example
rm -r build ios/.symlinks ios/Podfile.lock
flutter clean
flutter pub get
cd ios
pod install
cd ..
```

### Debug the example

If everything good, you are now ready to run the example in debug mode using either Visual Studio Code, Android Studio or XCode

- To debug/develop the Dart side, you open the project tau10/tau_sound/example/ in Visual Studio Code or Android Studio.
- To debug/develop the iOS side you open tau10/tau_sound/example/ios/Runner.xcworkspace in XCode.
- To debug/develop the Android side, you open the project tau10/tau_sound/example/android in Android Studio

### Debug your own App

You must change the dependencies in your pubspec.yaml file and do a `flutter pub get`:

```yaml
# ============================================================================
# The following instructions are just for developing/debugging Flutter Sound
# Do not put them in a real App
  tau_platform_interface:
    path: ../tau10/tau_platform_interface # flutter_sound_platform_interface Dir
  flutter_sound_web:
    path: ../tau10/tau_web # flutter_sound_web Dir
  flutter_sound: 
    path: ../tau10/flutter_sound
# ============================================================================
```

## Update the documentation

&tau; uses the Jekyll tool with a "Documentation Theme" to generate the documentation.
[Here](https://idratherbewriting.com/documentation-theme-jekyll/) is the Jekyll documentation.
Please refer to this documentation to install ruby and jekyll on your dev machine.

All the &tau; documentation is in markdown files under tau/doc/pages.
You can see your modifications in live doing:

```sh
cd tau10/doc
jekyll serve
```

Then, if you have the necessary credentials (but you certainly do not have them), you can do:

```sh
cd tau10
bin/doc.sh
```

## Build a new release

if you have the necessary credentials (but you certainly do not have them), you can do:

```sh
cd tau10
doc/build.sh 9.0.0
```

(In this example, 9.0.0 is the version number that you want to build).

When the script asks if OK to upload your new flutter_sound plugin,
it is a good idea to wait something like half an hour before answering.
This will give time to `npm` and `cocoaPod` to update their repositories (you do not want that someone will use your new build before all the repositories are updated.

------------------

When you have finished your contribution, you commit and push your files, and do a Pull Request in the Github &tau; Project.

**THANK YOU FOR YOUR CONTRIBUTION**
