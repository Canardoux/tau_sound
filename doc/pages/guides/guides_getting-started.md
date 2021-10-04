---
title:  "Getting Started"
description: "Getting Started.."
summary: "Introduction for Flutter Sound beginners."
permalink: guides_getting_started.html
tags: [getting_started,guide]
keywords: gettingStarted
---

# Getting Started

## Playback

The complete running example [is there](flutter_sound_examples_simple_playback.html)

### 1. TauPlayer instanciation

To play back something you must [instanciate a player](tau_api_player_constructor.html). Most of the time, you will need just one player, and you can place this instanciation in the variables initialisation of your class :

```dart
  import 'tau_sound/tau_sound.dart';
...
  TauPlayer _myPlayer = TauPlayer();
```

### 2. open() and close() the player

Before calling [the verb play()](tau_api_player_startPlayer.html) you must [open() your player](tau_api_player_open_audio_session.html).
During this call, the App specifies the [Input Node](TODO) and the [Output Node](TODO) that the player must use.

When you have finished with it, **you must** [close your player](TODO). Calling `close()` on a not open player is no problem and is ignored. 
Calling `close()` on a Player which is currently playing will automatically `stop()` it before `close()` it. 
A good places to put this verb is in the procedure `dispose()`.

```dart
    InputNode from = InputFileNode(_exampleAudioFilePathMP3, codec: Mp3());
    OutputNode to = DefaultOutputDevice();
    // open() returns a Future but you do not need to wait for its completion before playing it.
    _myPlayer.open(from: from, to: to,);



  @override
  void dispose() {
    // Be careful : you must `close` the audio session when you have finished with it.
    _myPlayer.close(); // It does not arm to call this verb, even if the player is not yet open
    _myPlayer = null;
    super.dispose();
  }
```

### 3. play() your sound

To play a sound you call [the verb play()](tau_api_player_startPlayer.html). To stop a sound you call [the verb stop()](tau_api_player_stop_player.html).
Calling `stop()` on a not playing Player (paused or stopped) is no problem and is ignored.
Calling `stop()` on a not open is no problem and is ignored.

`play()` returns a future which is completed very early, when the player is correctly initialized, and not when the playback is finished.
If the App wants to control when the playback is finished, it specifies a Callback Function to be executed when finished.

```dart
    await _myPlayer.play(
      whenFinished: (){...}
    );

    ....
    await _myPlayer.pause();
    ....
    await _myPlayer.resume();  
    ....

    await _myPlayer.stopPlayer();
```

## Recording

The complete running example [is there](flutter_sound_examples_simple_recorder.html)

### 1. TauRecorder instanciation

To record something you must instanciate a recorder. Most of the time, you will need just one recorder, and you can place this instanciation in the variables initialisation of your class :

```dart
  TauRecorder _myRecorder = TauRecorder();
```

### 2. open() and close() the recorder

Before calling [the verb record()](tau_api_recorder_start_recorder.html) you must [open() your recorder](tau_api_recorder_open_audio_session.html).
During this call, the App specifies the [Input Node](TODO) and the [Output Node](TODO) that the recorder must use.

When you have finished with it, **you must** [close your recorder](TODO). A good place to put this verb is in the procedures `dispose()`.
Calling `close()` on a not open recorder is no problem and is ignored. 
Calling `close()` on a Recorder which is currently recording will automatically `stop()` it before `close()` it. 
A good places to put this verb is in the procedure `dispose()`.

```dart
    InputNode from = InputDeviceNode.mic();
    OutputNode to = OutputFileNode(_exampleAudioFilePath, codec: Opus.ogg());
    // open() returns a Future but you do not need to await for its completion before starting your recorder.
    _myRecorder.open(from: from, to: to,);



  @override
  void dispose() {
    // Be careful : you must `close` the audio session when you have finished with it.
    _myRecorder.close(); // It does not arm to call this verb, even if the recorder is not yet open
    _myRecorder = null;
    super.dispose();
  }
```

### 3. Record something

To record something you call [the verb record()](tau_api_recorder_start_recorder.html). To stop the recorder you call [the verb stop()](TODO)

```dart
    await _myRecorder.record();

    ...
    _myRecorder.pause();
    ...
    _myRecorder.resume();
    ...

    await _myRecorder.stop();
```

