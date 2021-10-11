---
title: The &tau; (tau) Project
description: The d&tau; Project README
keywords: home homepage readme
tags: [tau]
permalink: readme.html
summary: The &tau; Project documentation.
---

{% include image.html file="banner5.png"  caption="The &tau; (tau) Project" %}


![pub version](https://img.shields.io/pub/v/tau_sound.svg?style=flat-square)
{% include tip.html content="
This is the GPL branch of Flutter Sound. If you cannot (or don't want to) publish your App under the GPL License, you can consider using the [MPL branch](https://tau.canardoux.xyz/readme.html)
" %}

The τ (tau) Project (or simply **"τ"**) is a set of libraries which deal with audio :

* A player for audio playback
* A recorder for recording audio
* An Audio Graph engine 
* Several utilities to handle audio files

## Supported targets

τ is a library package allowing you to play and record audio for

* iOS
* Android
* Web

Later, τ will support also :
- Linux
- Macos
- Windows

## Overview

τ provides both a high level API and widgets for:

* play audio
* record audio

τ can be used to play a beep from an asset all the way up to implementing a complete media player.

The API is designed so you can use the supplied widgets or roll your own.

The τ package supports playback from:

* Assets
* Files
* URL
* Streams
* Remote URI

## SDK requirements

* τ requires an iOS 10.0 SDK \(or later\)
* τ requires an Android 21 \(or later\)

## Examples \(Demo Apps\)

τ comes with several Demo/Examples :

[The `examples App`](https://github.com/Canardoux/tau/blob/main/tau_sound/example/lib/main.dart) is a driver which can call all the various examples.

## Features

The τ package includes the following features :

* Play and Record τ or music with various codecs. \(See [the supported codecs here](guides_codec.html)\)
* Play local or remote files specified by their URL.
* Play assets.
* Record to a live stream Stream
* Playback from a live Stream
* The App playback can be controlled from the device lock screen or from an Apple watch
* Play audio using the built in \[SoundPlayerUI\] Widget.
* Roll your own UI utilizing the τ api.
* Record audio using the builtin \[SoundRecorderUI\] Widget.
* Roll your own Recording UI utilizing the τ api.
* Support for releasing/resuming resources when the app pauses/resumes.
* Record to a Dart Stream
* Playback from a Dart Stream
* The App playback can be controlled from the device lock screen or from an Apple watch

## Supported frameworks

τ is actually supported by the following frameworks:

* Flutter \(Flutter Sound\)

τ will eventually be supported in the future by other frameworks :
- React Native, 
- Cordova, 
- JS (React JS, Vue, Pure JS), 
- ...


## Licenses

Flutter Sound 8.3 was published under the LGPL License.
A Flutter Sound developer noticed recently that this [license was incorrect](https://github.com/Canardoux/tau/issues/696) :
the LGPL license does not allow static links to the library. The library must be linked dynamically.
The problem was that Flutter links-edit the plugins statically. This means that many Flutter Sound users who
use our library in private/close sources App was in a copyright infringement.

To solve this issue, we forked Flutter Sound 8.3 to two different branches.

* [Flutter Sound 8.4](https://pub.dev/packages/flutter_sound) is published under the permissive Mozilla Public License 2.0.
* The τ Sound Project 9.0 (this fork) is published under a pure GPL License.

τ Sound is copyrighted by Canardoux (2021).

* τ Sound is released under a license with a *strong copyleft* clause: the GPL-V3 license. This means that if you use total or part of τ Sound, your App must be published under the GPL License too.
* If you cannot (or don't want to) publish your App under the GPL License, perhaps you can consider using the MPL [Flutter Sound 8.4 branch](https://tau.canardoux.xyz/readme.html).

## We need help

τ is a fundamental building block needed by almost every mobile project.

We are looking to make τ the go to project for mobile Audio with support for various platforms and various OS.

τ is a large and complex project which requires to maintain multiple hardware platforms and test environments.

{% include important.html content="We greatly appreciate any contributions to the project which can be as simple as providing feedback on the API or documentation."%}


## Thanks

Too many projects to manage. I am burning out slowly. If you could help me cheer up, buy me a cup of coffee will make my life really happy and get much energy out of it. As a side effect, we will know that the τ Project is important for you, that you appreciate our job and that you can show it with a little money.

<a href="https://www.buymeacoffee.com/larpoux"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=💛&slug=larpoux&button_colour=5F7FFF&font_colour=ffffff&font_family=Cookie&outline_colour=000000&coffee_colour=FFDD00"></a>
[![Paypal](https://www.paypalobjects.com/webstatic/mktg/Logo/pp-logo-100px.png)](https://paypal.me/thetauproject?locale.x=fr_FR)

{% include note.html content="You can also click on the `Thumb up` button of the top of the [pub.dev page](https://pub.dev/packages/flutter_sound).
This is free and this will reassure me that **I do not spend most of my life for nobody**." %}

<script data-name="BMC-Widget" src="http://cdnjs.buymeacoffee.com/1.0.0/widget.prod.min.js" data-id="larpoux" data-description="Support me on Buy me a coffee!" data-message="Thank you for visiting. You can now buy me a coffee!" data-color="#5F7FFF" data-position="Right" data-x_margin="18" data-y_margin="18"></script>

