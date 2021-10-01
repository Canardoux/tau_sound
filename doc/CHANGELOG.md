---
title: "The &tau; CHANGELOG"
keywords: changelog
tags: [changelog]
sidebar: mydoc_sidebar
permalink: changelog.html
summary: The Changelog of The &tau; Project.
toc: false
---
## 9.0.0-alpha.6

- Tau Sound and tau-native are now published under GPL3.0 . [FS #696](https://github.com/Canardoux/tau/issues/696). See [here](tau_sound_birth-post.html)
- Tau Sound FULL is now correctly linked with Flutter_ffmpeg. This means that if the App needs to access flutter_ffmpeg, it can use either the FULL flavor or the LITE flavor as it wants. [install](https://tau.canardoux.xyz/flutter_sound_install.html#ffmpeg). Goodbye the old hack :-)
- A new API V9 is offered (beta). Please refer to [this migration guide](links_migration_v9). The V6 API continues to be supported (backward compatibility is ensured) thanks to deprecated classes.
- Not necessary anymore to do any include inside index.html for Tau Sound on Web. We probably will have less Problem Reports from τ users not able to run their Web App.
- Remove the stupid assets in tau_web [FS #402](https://github.com/Canardoux/tau/issues/402)
