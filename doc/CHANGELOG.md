---
title: "The &tau; CHANGELOG"
keywords: changelog
tags: [changelog]
sidebar: mydoc_sidebar
permalink: changelog.html
summary: The Changelog of The &tau; Project.
toc: false
---
## 9.0.0-alpha.13

- τ Sound and τ Native are now published under GPL3.0 . [FS #696](https://github.com/Canardoux/tau/issues/696). See [here](tau_sound_birth-post.html)
- τ Sound FULL flavor is now correctly linked with Flutter_ffmpeg. This means that if the App needs to access flutter_ffmpeg, it can use either the FULL flavor or the LITE flavor as it wants. [install](flutter_sound_install.html#ffmpeg). Goodbye the old hack :-)
- A new API V9 is offered (beta). Please refer to [this migration guide](links_migration_v9). The V6 API continues to be supported (backward compatibility is ensured) thanks to deprecated classes.
- Not necessary anymore to do any include inside index.html for Tau Sound on Web. We probably will have less Problem Reports from τ users not able to run their Web App.
- Remove the stupid assets in tau_web [FS #402](https://github.com/Canardoux/tau/issues/402)
- Fix all the 404 errors in the documentation of the Dart API
- No more crashes with Just Audio compatibility. [FS #767](https://github.com/Canardoux/tau/issues/767)
- Added support to play audio files from assets. [FS #549](https://github.com/Canardoux/tau/issues/549)
- When the App wants to play a remote file, the file is downloaded asynchronously. [#762](https://github.com/Canardoux/flutter_sound/issues/762) and [#771](https://github.com/Canardoux/flutter_sound/issues/771). Thanks to Alvarocda who did a very good job on this issue. Now there are two things that we probably want to do in the future : 
   - Download the file in the `open()` verb instead of `play()`
   - Do not keep the semaphore so long, during the download, and allow the use of `close()` during the download.