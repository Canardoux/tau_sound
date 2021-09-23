---
title:  "Lite/Full"
description: "Lite flavor vs Full flavor"
summary: "Flutter Sound comes with two flavors: LITE and FULL."
permalink: guides_lite-full.html
tags: [flutter_sound]
keywords: Flutter, &tau;
---
# Flutter Sound comes with two flavors: LITE and FULL.

## The FULL flavor

Flutter Sound FULL flavor is linked with Mobile the FFmpeg library.
This library is huge.
Thanks to this library, Flutter Sound can support non native Codecs.
For example, Flutter Sound can record OPUS-OGG on iOS.

To use the FULL flavor, you must specify this dependency  in your pubspec.yaml:

```dart
        flutter_sound: ^8.2.5
```

## The LITE flavor

The LITE flavor of Flutter Sound does not include the Mobile FFmpeg library.
Actually this is the only difference with the FULL flavor.

Probably later this version will have others differences.

To use the LITE flavor, you must specify this dependency  in your pubspec.yaml:

```dart
        flutter_sound_lite: ^8.2.5
```

The import instruction in your dart code is the same as in the FULL flavor:

```dart
import 'package:flutter_sound/flutter_sound.dart';
```

## Using flutter_ffmpeg

If your app needs to use flutter_ffmpeg, you can use either the LITE flavor or the light flavor.
If you decide to use the FULL flavor, it is not necessary that you link the iOS code
and the Android code with the MobileFFmpeg library : Flutter Sound FULL is already linked
with this library