---
title:  "Migration"
description: "Migration from 8.x.x to 9.x.x"
summary: "Migration from previous version"
permalink: links_migration_v9.html
tags: [migration]
keywords: migration
---

The V9 API is backward compatible with the V8 API.
The deprecated modules (FlutterSoundPlayer, FlutterSoundRecorder and FlutterSoundHelper) are still released.
The App will be able to switch to the new modules (TauPlayer, TauRecorder and TauHelper) when
it will be ready to do it.

## flutter_sound_ffmpeg

The flutter_sound_ffmpeg is obsolete.
Flutter Sound uses now a regular official version of flutter_ffmpeg in the FULL flavor of Flutter Sound.
If your App needs to access flutter_ffmpeg, it just has to add the dependency is the FULL flavor of pubspec.yaml.
It does not need anymore to use the LITE flavor.
It does not need to link his App with the Mobile FFmpeg library, because it is already don by Flutter Sound.

## Config

Your pubspec.yaml must define a dependency to the new Flutter Sound version

```yaml
  flutter_sound: ^9.0.0
```

If you use Flutter Sound on web and import the sources from the public library
you must change the version from `@8` to `@9` in your index.html file.

```html
  <script src="https://cdn.jsdelivr.net/npm/tau_core@9/js/flutter_sound/flutter_sound.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/tau_core@9/js/flutter_sound/flutter_sound_player.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/tau_core@9/js/flutter_sound/flutter_sound_recorder.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/howler@2/dist/howler.min.js"></script>
```

## TauPlayer

The TauPlayer module replaces the FlutterSoundPlayer module.

## TauRecorder

The TauRecorder module replaces the FlutterSoundRecorder module.

## TauHelper

The TauPlayer module replaces the FlutterSoundHelper module.
