/*
 * Copyright 2021 Canardoux.
 *
 * This file is part of the τ Sound project.
 *
 * τ Sound is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Public License version 3 (GPL3.0),
 * as published by the Free Software Foundation.
 *
 * τ Sound is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * This Source Code Form is subject to the terms of the GNU Public
 * License, v. 3.0. If a copy of the GPL was not distributed with this
 * file, You can obtain one at https://www.gnu.org/licenses/.
 */

/// **THE** Flutter Sound Player
/// {@category Main}
library player;

import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:io' show Platform;
import 'dart:typed_data' show Uint8List;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:logger/logger.dart' show Level, Logger;
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';
import 'package:tau_platform_interface/tau_player_platform_interface.dart';

import '../tau_sound.dart';

/// The possible states of the Player.
enum PlayerState {
  /// Player is stopped
  isStopped,

  /// Player is playing
  isPlaying,

  /// Player is paused
  isPaused,
}

/// Playback function type for [FlutterSoundPlayer.startPlayer()].
///
/// Note : this type must include a parameter with a reference to the FlutterSoundPlayer object involved.
typedef TWhenFinished = void Function();

//--------------------------------------------------------------------------------------------------------------------------------------------

/// A Player is an object that can playback from Files, Buffers and Assets. Players do not manage RAW PCM data.
/// Players play to a speaker or a headset.
/// A Player is a High level OS object. It corresponds to an AVAudioPlayer on iOS and a MediaPlayer on Android.
/// The App can create several Players. Each player must be independently opened and closed.
/// Each Player manages its own playback, with its own sound volume, its own seekToPlayer and its own set of callbacks.
/// When you have finished with a Player, you must close it.
/// Opening a player takes resources inside the OS. Those resources are freed with the verb [close()].
///
/// ----------------------------------------------------------------------------------------------------
///
/// Using a player is very simple :
///
/// 1. Create a new [TauPlayer()]
///
/// 2. Open it with [open()]
///
/// 3. Start your playback with [play()].
///
/// 4. Use the various verbs (optional):
///    - [pause()]
///    - [resume()]
///    - ...
///
/// 5. Stop your player : [stop()]
///
/// 6. Release your player when you have finished with it : [close()].
/// This verb will call [stop()] if necessary.
///
/// ----------------------------------------------------------------------------------------------------
class TauPlayer implements TauPlayerCallback {
  //============================================ New API V9 ===================================================================

  /// Instanciate a new TauPlayer.
  /// The optional parameter [logLevel] specify the Logger Level you are interested by.
  /* ctor */ TauPlayer({Level logLevel = Level.debug}) {
    _logger = Logger(level: logLevel);
    _logger.d('ctor: TauPlayer()');
  }

  /// The TauPlayerLogger Logger getter
  Logger get logger => _logger;

  /// True if the Player has been open
  bool get isOpen => _isInited;

  /// The current state of the Player
  PlayerState get playerState => _playerState;

  /// Test the Player State
  bool get isPlaying => _playerState == PlayerState.isPlaying;

  /// Test the Player State
  bool get isPaused => _playerState == PlayerState.isPaused;

  /// Test the Player State
  bool get isStopped => _playerState == PlayerState.isStopped;

  /// The stream side of the Food Controller
  ///
  /// This is a stream on which FlutterSound will post the player progression.
  /// You may listen to this Stream to have feedback on the current playback.
  ///
  /// PlaybackDisposition has two fields :
  /// - Duration duration  (the total playback duration)
  /// - Duration position  (the current playback position)
  ///
  /// *Example:*
  /// ```dart
  ///         _playerSubscription = myPlayer.onProgress.listen((e)
  ///         {
  ///                 Duration maxDuration = e.duration;
  ///                 Duration position = e.position;
  ///                 ...
  ///         }
  /// ```
  Stream<PlaybackDisposition>? get onProgress =>
      _playerController != null ? _playerController!.stream : null;

  /// Used if the App wants to dynamically change the Log Level.
  /// Seldom used. Most of the time the Log Level is specified during the constructor.
  Future<void> setLogLevel(Level aLevel) async {
    _logLevel = aLevel;
    _logger = Logger(level: aLevel);
    await _lock.synchronized(() async {
      if (_isInited) {
        await TauPlayerPlatform.instance.setLogLevel(
          this,
          aLevel,
        );
      }
    });
  }

  /// Open the Player.
  ///
  /// A player must be opened before used. A player correspond to an Audio Session.
  /// A Player manages its own playback, with its own sound volume, its own seekToPlayer and its own set of callbacks.
  /// A Player is a High level OS object. It corresponds to an AVAudioPlayer on iOS and a MediaPlayer on Android.
  /// Players play Files, Buffers and Assets. Players do not manage RAW PCM data.
  ///
  /// The App can create several Players. Each player must be independently opened and closed.
  /// When you have finished with a Player, you must close it.
  /// Opening a player takes resources inside the OS. Those resources are freed with the verb [close()].
  /// Returns a Future, but the App does not need to wait the completion of this future before doing a [start()].
  /// The Future will be automaticaly awaited by [start()]
  ///
  /// - [focus] : What to do with the focus. Useful if you want to open a player and at the same time acquire the focus.
  /// But be aware that the focus is a global resource for the App:
  /// If you have several players, you cannot handle their focus independantely.
  /// If this parameter is not specified, the Focus will be acquired with stop others
  ///
  /// *Example:*
  /// ```dart
  ///     myPlayer = await TauPlayer().open();
  ///
  ///     ...
  ///     (do something with myPlayer)
  ///     ...
  ///
  ///     await myPlayer.close();
  ///     myPlayer = null;
  /// ```
  Future<TauPlayer?> open({
    required InputNode from,
    required OutputDeviceNode to,
    AudioFocus? focus,
    SessionCategory category = SessionCategory.playAndRecord,
    SessionMode mode = SessionMode.modeDefault,
    //AudioDevice device = AudioDevice.speaker,
    int audioFlags = outputToSpeaker | allowBlueToothA2DP | allowAirPlay,
  }) async {
    if (_isInited) {
      return this;
    }
    TauPlayer? r;
    await _lock.synchronized(() async {
      _from = from;
      _to = to;
      r = await _open(
        from: from,
        to: to,
        focus: focus,
        category: category,
        mode: mode,
        //device: device,
        audioFlags: audioFlags,
      );
    });
    return r;
  }

  /// Close an open session.
  ///
  /// Must be called when finished with a Player, to release all the resources.
  /// It is safe to call this procedure at any time.
  /// - If the Player is not open, this verb will do nothing
  /// - If the Player is currently in play or pause mode, it will be stopped before.
  ///
  /// If there is no more Player open and the parameter [keepFocus] is not set
  /// then the focus is abandoned
  ///
  /// example:
  /// ```dart
  /// @override
  /// void dispose()
  /// {
  ///         if (myPlayer != null)
  ///         {
  ///             myPlayer.close();
  ///             myPlayer = null;
  ///         }
  ///         super.dispose();
  /// }
  /// ```
  Future<void> close({
    bool? keepFocus,
  }) async {
    await _lock.synchronized(() async {
      await _close(keepFocus: keepFocus);
    });
  }

  /// setAudioFocus is used to modify the state of the Focus.
  /// Very often, the App will not use this verb and will specify the focus value
  /// during the [open()] and [close()] verbs.
  /// If the App does not have the focus when it does a [start()]
  /// it automaticaly gets the focus `AudioFocus.requestFocusAndStopOthers`,
  /// and releases the focus automaticaly when the Player is stopped.
  ///
  /// Be aware that the focus is a global resource for the App:
  /// If you have several players, you cannot handle their focus independantely.
  ///
  /// *Example:*
  /// ```dart
  ///         myPlayer.setFocus(focus: AudioFocus.requestFocusAndDuckOthers);
  /// ```
  Future<void> setAudioFocus({
    AudioFocus focus = AudioFocus.requestFocusAndKeepOthers,
    SessionCategory category = SessionCategory.playback,
    SessionMode mode = SessionMode.modeDefault,
    //AudioDevice device = AudioDevice.speaker,
    int audioFlags =
        outputToSpeaker | allowBlueTooth | allowBlueToothA2DP | allowEarPiece,
  }) async {
    await _lock.synchronized(() async {
      await _setAudioFocus(
        focus: focus,
        category: category,
        mode: mode,
        //device: device,
        audioFlags: audioFlags,
      );
    });
  }

  /// Used to play a sound.
  //
  /// - `startPlayer()` has three optional parameters, depending on your sound source :
  ///    - `fromUri:`  (if you want to play a file or a remote URI)
  ///    - `fromDataBuffer:` (if you want to play from a data buffer)
  ///    - `sampleRate` is mandatory if `codec` == `Codec.pcm16`. Not used for other codecs.
  ///
  /// You must specify one or the three parameters : `fromUri`, `fromDataBuffer`, `fromStream`.
  ///
  /// - You use the optional parameter`codec:` for specifying the audio and file format of the file. Please refer to the [Codec compatibility Table](/guides_codec.html) to know which codecs are currently supported.
  ///
  /// - `whenFinished:()` : A lambda function for specifying what to do when the playback will be finished.
  ///
  /// Very often, the `codec:` parameter is not useful. Flutter Sound will adapt itself depending on the real format of the file provided.
  /// But this parameter is necessary when Flutter Sound must do format conversion (for example to play opusOGG on iOS).
  ///
  /// `startPlayer()` returns a Duration Future, which is the record duration.
  ///
  /// The `fromUri` parameter, if specified, can be one of three posibilities :
  /// - The URL of a remote file
  /// - The path of a local file
  /// - The name of a temporary file (without any slash '/')
  ///
  /// Hint: [path_provider](https://pub.dev/packages/path_provider) can be useful if you want to get access to some dire'ctor'ies on your device.
  ///
  ///
  /// *Example:*
  /// ```dart
  ///         Duration d = await myPlayer.startPlayer(fromURI: 'foo', codec: Codec.aacADTS); // Play a temporary file
  ///
  ///         _playerSubscription = myPlayer.onProgress.listen((e)
  ///         {
  ///                 // ...
  ///         });
  /// }
  /// ```
  ///
  /// *Example:*
  /// ```dart
  ///     final fileUri = "https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3";
  ///
  ///     Duration d = await myPlayer.startPlayer
  ///     (
  ///                 fromURI: fileUri,
  ///                 codec: Codec.mp3,
  ///                 whenFinished: ()
  ///                 {
  ///                          logger.d( 'I hope you enjoyed listening to this song' );
  ///                 },
  ///     );
  /// ```
  Future<Duration?> play({
    TWhenFinished? whenFinished,
  }) async {
    Duration? r;
    await _lock.synchronized(() async {
      r = await _play();
    });
    return r;
  }

  /// Stop a playback.
  ///
  /// This verb never throw any exception. It is safe to call it everywhere,
  /// for example when the App is not sure of the current Audio State and want to recover a clean reset state.
  ///
  /// *Example:*
  /// ```dart
  ///         await myPlayer.stopPlayer();
  ///         if (_playerSubscription != null)
  ///         {
  ///                 _playerSubscription.cancel();
  ///                 _playerSubscription = null;
  ///         }
  /// ```
  Future<void> stop() async {
    await _lock.synchronized(() async {
      await _stopPlayer();
    });
  }

  /// Pause the current playback.
  ///
  /// An exception is thrown if the player is not in the "playing" state.
  ///
  /// *Example:*
  /// ```dart
  /// await myPlayer.pausePlayer();
  /// ```
  Future<void> pause() async {
    _logger.d('FS:---> pausePlayer ');
    await _lock.synchronized(() async {
      await _pausePlayer();
    });
    _logger.d('FS:<--- pausePlayer ');
  }

  /// Resume the current playback.
  ///
  /// An exception is thrown if the player is not in the "paused" state.
  ///
  /// *Example:*
  /// ```dart
  /// await myPlayer.resumePlayer();
  /// ```
  Future<void> resume() async {
    _logger.d('FS:---> resumePlayer');
    await _lock.synchronized(() async {
      await _resumePlayer();
    });
    _logger.d('FS:<--- resumePlayer');
  }

  /// To seek to a new location.
  ///
  /// The player must already be playing or paused. If not, an exception is thrown.
  ///
  /// *Example:*
  /// ```dart
  /// await myPlayer.seekToPlayer(Duration(milliseconds: milliSecs));
  /// ```
  Future<void> seekTo(Duration duration) async {
    await _lock.synchronized(() async {
      await _seekToPlayer(duration);
    });
  }

  /// Change the output volume
  ///
  /// The parameter is a floating point number between 0 and 1.
  /// Volume can be changed when player is running or before [startPlayer].
  ///
  /// *Example:*
  /// ```dart
  /// await myPlayer.setVolume(0.1);
  /// ```
  Future<void> setVolume(double volume) async {
    await _lock.synchronized(() async {
      await _setVolume(volume);
    });
  }

  /// Change the playback speed
  ///
  /// The parameter is a floating point number between 0 and 1.0 to slow the speed,
  /// or 1.0 to n to accelerate the speed.
  ///
  /// Speed can be changed when player is running, or before [startPlayer].
  ///
  /// *Example:*
  /// ```dart
  /// await myPlayer.setSpeed(0.8);
  /// ```
  Future<void> setSpeed(double speed) async {
    await _lock.synchronized(() async {
      await _setSpeed(speed);
    });
  }

  /// Specify the callbacks frenquency, before calling [startPlayer].
  ///
  /// The default value is 0 (zero) which means that there is no callbacks.
  ///
  /// This verb will be Deprecated soon.
  ///
  /// *Example:*
  /// ```dart
  /// myPlayer.setSubscriptionDuration(Duration(milliseconds: 100));
  /// ```
  Future<void> setSubscriptionDuration(Duration duration) async {
    _logger.d('FS:---> setSubscriptionDuration ');
    await _waitOpen();
    if (!_isInited) {
      throw Exception('Player is not open');
    }
    var state = await TauPlayerPlatform.instance
        .setSubscriptionDuration(this, duration: duration);
    _playerState = PlayerState.values[state];
    _playerStateController?.add(_playerState);
    _logger.d('FS:<---- setSubscriptionDuration ');
  }

  /// Get the resource path.
  ///
  /// This verb should probably not be here...
  Future<String?> getResourcePath() async {
    await _waitOpen();
    if (!_isInited) {
      throw Exception('Player is not open');
    }
    if (kIsWeb) {
      return null;
    } else if (Platform.isIOS) {
      var s = await TauPlayerPlatform.instance.getResourcePath(this);
      return s;
    } else {
      return (await getApplicationDocumentsDirectory()).path;
    }
  }

  ///  Used when you want to play live PCM data synchronously.
  ///
  ///  This procedure returns a Future. It is very important that you wait that this Future is completed before trying to play another buffer.
  ///
  ///  *Example:*
  ///
  ///  - [This example](../flutter_sound/example/example.md#liveplaybackwithbackpressure) shows how to play Live data, with Back Pressure from Flutter Sound
  ///  - [This example](../flutter_sound/example/example.md#soundeffect) shows how to play some real time sound effects synchronously.
  ///
  ///  ```dart
  ///  await myPlayer.startPlayerFromStream(codec: Codec.pcm16, numChannels: 1, sampleRate: 48000);
  ///
  ///  await myPlayer.feedFromStream(aBuffer);
  ///  await myPlayer.feedFromStream(anotherBuffer);
  ///  await myPlayer.feedFromStream(myOtherBuffer);
  ///
  ///  await myPlayer.stopPlayer();
  ///  ```
  Future<void> feedFromStream(Uint8List buffer) async {
    await _feedFromStream(buffer);
  }

  /// Returns true if the specified decoder is supported by flutter_sound on this platform
  ///
  /// *Example:*
  /// ```dart
  ///         if ( await myPlayer.isDecoderSupported(Codec.opusOGG) ) doSomething;
  /// ```
  Future<bool> isDecoderSupported(TauCodec codec) async {
    var result = false;
    _logger.d('FS:---> isDecoderSupported ');
    await _waitOpen();
    if (!_isInited) {
      throw Exception('Player is not open');
    }
    // For decoding ogg/opus on ios, we need to support two steps :
    // - remux OGG file format to CAF file format (with ffmpeg)
    // - decode CAF/OPPUS (with native Apple AVFoundation)

    result = await TauPlayerPlatform.instance
        .isDecoderSupported(this, codec: codec.deprecatedCodec);
    _logger.d('FS:<--- isDecoderSupported ');
    return result;
  }

  /// Query the current state to the Tau Core layer.
  ///
  /// Most of the time, the App will not use this verb,
  /// but will use the [playerState] variable.
  /// This is seldom used when the App wants to get
  /// an updated value the background state.
  Future<PlayerState> getPlayerState() async {
    await _waitOpen();
    if (!_isInited) {
      throw Exception('Player is not open');
    }
    var state = await TauPlayerPlatform.instance.getPlayerState(this);
    _playerState = PlayerState.values[state];
    _playerStateController?.add(_playerState);
    return _playerState;
  }

  /// Get the current progress of a playback.
  ///
  /// It returns a `Map` with two Duration entries : `'progress'` and `'duration'`.
  /// Remark : actually only implemented on iOS.
  ///
  /// *Example:*
  /// ```dart
  ///         Duration progress = (await getProgress())['progress'];
  ///         Duration duration = (await getProgress())['duration'];
  /// ```
  Future<Map<String, Duration>> getProgress() async {
    await _waitOpen();
    if (!_isInited) {
      throw Exception('Player is not open');
    }

    return TauPlayerPlatform.instance.getProgress(this);
  }

//--------------------------------------------- Locals --------------------------------------------------------------------

  /// Private variables
  Logger _logger = Logger(level: Level.debug);
  Level _logLevel = Level.debug;
  final _lock = Lock();
  bool _isInited = false;
  static bool _hasFocus = false;
  PlayerState _playerState = PlayerState.isStopped;

  /// User callback "whenFinished:"
  TWhenFinished? _audioPlayerFinishedPlaying;
  StreamController<PlaybackDisposition>? _playerController;
  StreamController<PlayerState>? _playerStateController;

  Stream<PlayerState> get onPlayerStateChanged =>
      _playerStateController!.stream;

  /// The default blocksize used when playing from Stream.
  static const _blockSize = 4096;

  //static bool _reStarted = true;

  InputNode? _from;
  OutputDeviceNode? _to;

  ///
  StreamSubscription<TauFood>?
      _foodStreamSubscription; // ignore: cancel_subscriptions

  ///
  Stream<TauFood>? _foodStream; //ignore: close_sinks

  ///
  static const List<Codec> _tabAndroidConvert = [
    Codec.defaultCodec, // defaultCodec
    Codec.defaultCodec, // aacADTS
    Codec.defaultCodec, // opusOGG
    Codec.opusOGG, // opusCAF
    Codec.defaultCodec, // mp3
    Codec.defaultCodec, // vorbisOGG
    Codec.defaultCodec, // pcm16
    Codec.defaultCodec, // pcm16WAV
    Codec.pcm16WAV, // pcm16AIFF
    Codec.pcm16WAV, // pcm16CAF
    Codec.defaultCodec, // flac
    Codec.defaultCodec, // aacMP4
    Codec.defaultCodec, // amrNB
    Codec.defaultCodec, // amrWB
    Codec.defaultCodec, // pcm8
    Codec.defaultCodec, // pcmFloat32
    Codec.defaultCodec, // pcmWebM
    Codec.defaultCodec, // opusWebM
    Codec.defaultCodec, // vorbisWebM
  ];

  ///
  static const List<Codec> _tabIosConvert = [
    Codec.defaultCodec, // defaultCodec
    Codec.defaultCodec, // aacADTS
    Codec.opusCAF, // opusOGG
    Codec.defaultCodec, // opusCAF
    Codec.defaultCodec, // mp3
    Codec.defaultCodec, // vorbisOGG
    Codec.defaultCodec, // pcm16
    Codec.defaultCodec, // pcm16WAV
    Codec.defaultCodec, // pcm16AIFF
    Codec.defaultCodec, // pcm16CAF
    Codec.defaultCodec, // flac
    Codec.defaultCodec, // aacMP4
    Codec.defaultCodec, // amrNB
    Codec.defaultCodec, // amrWB
    Codec.defaultCodec, // pcm8
    Codec.defaultCodec, // pcmFloat32
    Codec.defaultCodec, // pcmWebM
    Codec.defaultCodec, // opusWebM
    Codec.defaultCodec, // vorbisWebM
  ];

  ///
  static const List<Codec> _tabWebConvert = [
    Codec.defaultCodec, // defaultCodec
    Codec.defaultCodec, // aacADTS
    Codec.defaultCodec, // opusOGG
    Codec.defaultCodec, // opusCAF
    Codec.defaultCodec, // mp3
    Codec.defaultCodec, // vorbisOGG
    Codec.defaultCodec, // pcm16
    Codec.defaultCodec, // pcm16WAV
    Codec.defaultCodec, // pcm16AIFF
    Codec.defaultCodec, // pcm16CAF
    Codec.defaultCodec, // flac
    Codec.defaultCodec, // aacMP4
    Codec.defaultCodec, // amrNB
    Codec.defaultCodec, // amrWB
    Codec.defaultCodec, // pcm8
    Codec.defaultCodec, // pcmFloat32
    Codec.defaultCodec, // pcmWebM
    Codec.defaultCodec, // opusWebM
    Codec.defaultCodec, // vorbisWebM
  ];

  ///
  void _setPlayerCallback() {
    _playerController ??= StreamController<PlaybackDisposition>.broadcast();
  }

  void _removePlayerCallback() {
    _playerController?.close();
    _playerController = null;
  }

  Future<void> _waitOpen() async {
    while (_openPlayerCompleter != null) {
      _logger.d('Waiting for the player being opened');
      await _openPlayerCompleter!.future;
    }
    if (!_isInited) {
      throw Exception('Player is not open');
    }
  }

  Future<TauPlayer> _open({
    required InputNode from,
    required OutputDeviceNode to,
    AudioFocus? focus,
    SessionCategory category = SessionCategory.playAndRecord,
    SessionMode mode = SessionMode.modeDefault,
    //AudioDevice device = AudioDevice.speaker,
    int audioFlags = outputToSpeaker | allowBlueToothA2DP | allowAirPlay,
  }) async {
    _playerStateController ??= StreamController<PlayerState>.broadcast();
    _logger.d('FS:---> open()');
    while (_openPlayerCompleter != null) {
      _logger.w('Another openPlayer() in progress');
      await _openPlayerCompleter!.future;
    }

    Completer<TauPlayer>? completer;
    if (_isInited) {
      throw Exception('Player is already open');
    }

    //if (_reStarted) {
    // Perhaps a Hot Restart ?  We must reset the plugin
    //_logger.d('Resetting Tau Player Plugin');
    //_reStarted = false;
    //await FlutterSoundPlayerPlatform.instance.resetPlugin(this);
    //}

    focus ??= _hasFocus
        ? AudioFocus.doNotRequestFocus
        : AudioFocus.requestFocusAndStopOthers;
    TauPlayerPlatform.instance.openSession(this);
    _setPlayerCallback();
    _playerStateController?.add(PlayerState.isStopped);
    assert(_openPlayerCompleter == null);
    _openPlayerCompleter = Completer<TauPlayer>();
    completer = _openPlayerCompleter;
    try {
      var state = await TauPlayerPlatform.instance.openPlayer(
        this,
        logLevel: _logLevel,
        focus: focus,
        audioFlags: audioFlags,
        category: category,
        device: AudioDevice.obsolete,
        mode: mode,
      );
      if (focus != AudioFocus.doNotRequestFocus) {
        _hasFocus = focus != AudioFocus.abandonFocus;
      }
      _from = from;
      _to = to;
      _playerState = PlayerState.values[state];
      _playerStateController?.add(_playerState);
    } on Exception {
      _openPlayerCompleter = null;
      rethrow;
    }
    _logger.d('FS:<--- open()');
    return completer!.future;
  }

  Future<void> _close({
    bool? keepFocus,
  }) async {
    _logger.d('FS:---> close() ');

    // If another closePlayer() is already in progress, wait until finished
    while (_closePlayerCompleter != null) {
      _logger.w('Another closePlayer() in progress');
      await _closePlayerCompleter!.future;
    }

    if (!_isInited) {
      // Already closed
      _logger.d('Player already close');
      return;
    }

    Completer<void>? completer;
    try {
      await _stop(); // Stop the player if running

      _removePlayerCallback();
      assert(_closePlayerCompleter == null);
      _closePlayerCompleter = Completer<void>();
      completer = _closePlayerCompleter;
      keepFocus ??= (TauPlayerPlatform.instance.numberOfOpenSessions() > 1);
      if (!keepFocus && _hasFocus) {
        await _setAudioFocus(
            focus: AudioFocus.abandonFocus); // Abandon the focus
      }
      await TauPlayerPlatform.instance.closePlayer(this);
      TauPlayerPlatform.instance.closeSession(this);
    } on Exception {
      _closePlayerCompleter = null;
      rethrow;
    }
    _logger.d('FS:<--- close() ');
    return completer!.future;
  }

  Future<void> _setAudioFocus({
    AudioFocus focus = AudioFocus.requestFocusAndKeepOthers,
    SessionCategory category = SessionCategory.playback,
    SessionMode mode = SessionMode.modeDefault,
    //AudioDevice device = AudioDevice.obsolete,
    int audioFlags =
        outputToSpeaker | allowBlueTooth | allowBlueToothA2DP | allowEarPiece,
  }) async {
    _logger.d('FS:---> setAudioFocus ');
    await _waitOpen();
    if (!_isInited) {
      throw Exception('Player is not open');
    }
    if (focus != AudioFocus.doNotRequestFocus) {
      _hasFocus = focus != AudioFocus.abandonFocus;
    }
    var state = await TauPlayerPlatform.instance.setAudioFocus(
      this,
      focus: focus,
      category: category,
      mode: mode,
      audioFlags: audioFlags,
      device: AudioDevice.obsolete,
    );
    _playerState = PlayerState.values[state];
    _playerStateController?.add(_playerState);
    _logger.d('FS:<--- setAudioFocus ');
  }

  Future<PlayerState> _startPlayerFromURI(
    InputFileNode fromURI,
    OutputDeviceNode to,
  ) async {
    var uri = fromURI.uri;
    var codec = fromURI.codec;
    if (codec is Pcm && codec.audioFormat == AudioFormat.raw) {
      fromURI = await fromURI.toWave();
      uri = fromURI.uri;
      codec = fromURI.codec;
    }

    var state = PlayerState.isStopped.index;
    state = await TauPlayerPlatform.instance.startPlayer(
      this,
      codec: codec.deprecatedCodec,
      fromURI: uri,
      fromDataBuffer: null,
    );

    return PlayerState.values[state];
  }

  Future<PlayerState> _startPlayerFromAsset(
    InputAssetNode fromAsset,
    OutputDeviceNode to,
  ) async {
    final byteData = await rootBundle.load(fromAsset.path);
    var assetBuffer = byteData.buffer.asUint8List();
    var bufferNode = InputBufferNode(
      assetBuffer,
      codec: fromAsset.codec,
    );
    return await _startPlayerFromBuffer(
      bufferNode,
      to,
    );
  }

  Future<PlayerState> _startPlayerFromBuffer(
    InputBufferNode fromBuffer,
    OutputDeviceNode to,
  ) async {
    var buffer = fromBuffer.inputBuffer;
    var codec = fromBuffer.codec;
    if (codec is Pcm && codec.audioFormat == AudioFormat.raw) {
      fromBuffer = await fromBuffer.toWave();
      buffer = fromBuffer.inputBuffer;
      codec = fromBuffer.codec;
    }
    var oldCodec = codec.deprecatedCodec;

    var state = PlayerState.isStopped.index;
    state = await TauPlayerPlatform.instance.startPlayer(
      this,
      codec: codec.deprecatedCodec,
      fromDataBuffer: buffer,
      fromURI: null,
    );

    return PlayerState.values[state];
  }

  /// Used to play something from a Dart stream
  ///
  /// **This functionnality needs, at least, and Android SDK >= 21**
  ///
  ///   - The only codec supported is actually `Codec.pcm16`.
  ///   - The only value possible for `numChannels` is actually 1.
  ///   - SampleRate is the sample rate of the data you want to play.
  ///
  ///   Please look to [the following notice](codec.md#playing-pcm-16-from-a-dart-stream)
  ///
  ///   *Example*
  ///   You can look to the three provided examples :
  ///
  ///   - [This example](../flutter_sound/example/example.md#liveplaybackwithbackpressure) shows how to play Live data, with Back Pressure from Flutter Sound
  ///   - [This example](../flutter_sound/example/example.md#liveplaybackwithoutbackpressure) shows how to play Live data, without Back Pressure from Flutter Sound
  ///   - [This example](../flutter_sound/example/example.md#soundeffect) shows how to play some real time sound effects.
  ///
  ///   *Example 1:*
  ///   ```dart
  ///   await myPlayer.startPlayerFromStream(codec: Codec.pcm16, numChannels: 1, sampleRate: 48000);
  ///
  ///   await myPlayer.feedFromStream(aBuffer);
  ///   await myPlayer.feedFromStream(anotherBuffer);
  ///   await myPlayer.feedFromStream(myOtherBuffer);
  ///
  ///   await myPlayer.stopPlayer();
  ///   ```
  ///   *Example 2:*
  ///   ```dart
  ///   await myPlayer.startPlayerFromStream(codec: Codec.pcm16, numChannels: 1, sampleRate: 48000);
  ///
  ///   myPlayer._FoodSink.add(_FoodData(aBuffer));
  ///  myPlayer._FoodSink.add(_FoodData(anotherBuffer));
  ///   myPlayer._FoodSink.add(_FoodData(myOtherBuffer));
  ///
  ///   myPlayer._FoodSink.add(_FoodEvent((){_mPlayer.stopPlayer();}));
  ///   ```
  Future<PlayerState> _startPlayerFromStream(
    InputStreamNode stream,
    OutputDeviceNode to,
  ) async {
    _logger.d('FS:---> startPlayerFromStream ');

    _foodStream = stream.stream;
    _foodStreamSubscription = _foodStream!.listen((TauFood food) {
      _foodStreamSubscription!.pause(food.exec(this));
    });
    var codec = stream.codec as Pcm;
    var state = await TauPlayerPlatform.instance.startPlayer(this,
        codec: stream.codec.deprecatedCodec,
        fromDataBuffer: null,
        fromURI: null,
        numChannels: codec.nbrChannels(),
        sampleRate: codec.sampleRate);
    _playerState = PlayerState.values[state];
    _playerStateController?.add(_playerState);
    _logger.d('FS:<--- startPlayerFromStream ');
    return PlayerState.values[state];
  }

  /// Starts the Microphone and plays what is recorded.
  ///
  /// The Speaker is directely linked to the Microphone.
  /// There is no processing between the Microphone and the Speaker.
  /// If you want to process the data before playing them, actually you must define a loop between a [TauPlayer] and a [TauRecorder].
  /// (Please, look to [this example](http://www.canardoux.xyz/tau_sound/doc/pages/flutter-sound/api/topics/flutter_sound_examples_stream_loop.html)).
  ///
  /// Later, we will implement the _Tau Audio Graph_ concept, which will be a more general object.
  ///
  /// - `startPlayerFromMic()` has two optional parameters :
  ///    - `sampleRate:` the Sample Rate used. Optional. Only used on Android. The default value is probably a good choice and the App can ommit this optional parameter.
  ///    - `numChannels:` 1 for monophony, 2 for stereophony. Optional. Actually only monophony is implemented.
  ///
  /// `startPlayerFromMic()` returns a Future, which is completed when the Player is really started.
  ///
  /// *Example:*
  /// ```dart
  ///     await myPlayer.startPlayerFromMic();
  ///     ...
  ///     myPlayer.stopPlayer();
  /// ```
  Future<PlayerState> _startPlayerFromMic(
    InputDeviceNode mic,
    OutputDeviceNode to,
  ) async {
    _logger.d('FS:---> startPlayerFromMic ');
    var state = await TauPlayerPlatform.instance
        .startPlayerFromMic(this, numChannels: 1, sampleRate: 44000);
    _playerState = PlayerState.values[state];
    _playerStateController?.add(_playerState);
    _logger.d('FS:<--- startPlayerFromMic ');
    //return completer!.future;
    return PlayerState.values[state];
  }

  Future<Duration> _play({
    TWhenFinished? whenFinished,
  }) async {
    _logger.d('FS:---> startPlayer ');
    await _waitOpen();
    if (!_isInited) {
      throw Exception('Player is not open');
    }

    await _stop(); // Just in case

    Completer<Duration>? completer;
    _audioPlayerFinishedPlaying = whenFinished;
    if (_startPlayerCompleter != null) {
      _logger.w('Killing another startPlayer()');
      _startPlayerCompleter!.completeError('Killed by another startPlayer()');
    }

    try {
      _startPlayerCompleter = Completer<Duration>();
      completer = _startPlayerCompleter;

      //var r = Duration.zero;

      // We dispatch depending on the `from` class.
      // We could have used a virtual function in InputNode,
      // but I wanted to keep the InputNode hierarchy independant of `tauPlayer`
      var state = PlayerState.isPlaying;
      switch (_from.runtimeType) {
        case InputFileNode:
          state = await _startPlayerFromURI(
            _from as InputFileNode,
            _to!,
          );
          break;
        case InputAssetNode:
          state = await _startPlayerFromAsset(
            _from as InputAssetNode,
            _to!,
          );
          break;
        case InputBufferNode:
          state = await _startPlayerFromBuffer(
            _from as InputBufferNode,
            _to!,
          );
          break;
        case InputStreamNode:
          state = await _startPlayerFromStream(
            _from as InputStreamNode,
            _to!,
          );
          break;
        case InputDeviceNode:
          state = await _startPlayerFromMic(_from as InputDeviceNode, _to!);
          break;
        default:
          throw Exception('Invalid Input Node');
      }
      _playerState = state;
      _playerStateController?.add(state);
    } on Exception {
      _startPlayerCompleter = null;
      rethrow;
    }

    _logger.d('FS:<--- startPlayer ');
    return completer!.future;
  }

  Future<void> _stopPlayer() async {
    _logger.d('FS:---> _stopPlayer ');
    while (_openPlayerCompleter != null) {
      _logger.w('Waiting for the recorder being opened');
      await _openPlayerCompleter!.future;
    }
    if (!_isInited) {
      _logger.d('<--- _stopPlayer : Player is not open');
      return;
    }
    try {
      //_removePlayerCallback(); // playerController is closed by this function
      await _stop();
    } on Exception catch (e) {
      _logger.e(e);
    }
    _logger.d('FS:<--- stopPlayer ');
  }

  Future<void> _stop() async {
    _logger.d('FS:---> _stop ');
    if (_foodStreamSubscription != null) {
      await _foodStreamSubscription!.cancel();
      _foodStreamSubscription = null;
    }
    _needSomeFoodCompleter = null;
    //if (_foodStream != null) {
    //await _foodStreamController!.sink.close();
    //await _FoodStreamController.stream.drain<bool>();
    //await _foodStreamController!.close();
    _foodStream = null;
    //}
    Completer<void>? completer;
    _stopPlayerCompleter = Completer<void>();
    try {
      completer = _stopPlayerCompleter;
      var state = await TauPlayerPlatform.instance.stopPlayer(this);

      _playerState = PlayerState.values[state];
      _playerStateController?.add(_playerState);
      if (_playerState != PlayerState.isStopped) {
        _logger.d('Player is not stopped!');
      }
    } on Exception {
      _stopPlayerCompleter = null;
      rethrow;
    }

    _logger.d('FS:<--- _stop ');
    return completer!.future;
  }

  Future<void> _pausePlayer() async {
    _logger.d('FS:---> _pausePlayer ');
    await _waitOpen();
    if (!_isInited) {
      throw Exception('Player is not open');
    }
    Completer<void>? completer;
    if (_pausePlayerCompleter != null) {
      _logger.w('Killing another pausePlayer()');
      _pausePlayerCompleter!.completeError('Killed by another pausePlayer()');
    }
    try {
      _pausePlayerCompleter = Completer<void>();
      completer = _pausePlayerCompleter;
      _playerState = PlayerState
          .values[await TauPlayerPlatform.instance.pausePlayer(this)];
      _playerStateController?.add(_playerState);
      //if (_playerState != PlayerState.isPaused) {
      //throw _PlayerRunningException(
      //'Player is not paused.'); // I am not sure that it is good to throw an exception here
      //}
    } on Exception {
      _pausePlayerCompleter = null;
      rethrow;
    }

    _logger.d('FS:<--- _pausePlayer ');
    return completer!.future;
  }

  Future<void> _resumePlayer() async {
    _logger.d('FS:---> _resumePlayer');
    await _waitOpen();
    if (!_isInited) {
      throw Exception('Player is not open');
    }
    Completer<void>? completer;
    if (_resumePlayerCompleter != null) {
      _logger.w('Killing another resumePlayer()');
      _resumePlayerCompleter!.completeError('Killed by another resumePlayer()');
    }
    _resumePlayerCompleter = Completer<void>();
    try {
      completer = _resumePlayerCompleter;
      var state = await TauPlayerPlatform.instance.resumePlayer(this);
      _playerState = PlayerState.values[state];
      _playerStateController?.add(_playerState);
      //if (_playerState != PlayerState.isPlaying) {
      //throw _PlayerRunningException(
      //'Player is not resumed.'); // I am not sure that it is good to throw an exception here
      //}
    } on Exception {
      _resumePlayerCompleter = null;
      rethrow;
    }
    _logger.d('FS:<--- _resumePlayer');
    return completer!.future;
  }

  Future<void> _seekToPlayer(Duration duration) async {
    _logger.v('FS:---> seekToPlayer ');
    await _waitOpen();
    if (!_isInited) {
      throw Exception('Player is not open');
    }
    var state = await TauPlayerPlatform.instance.seekToPlayer(
      this,
      duration: duration,
    );
    _playerState = PlayerState.values[state];
    _playerStateController?.add(_playerState);
    _logger.v('FS:<--- seekToPlayer ');
  }

  Future<void> _setVolume(double volume) async {
    _logger.d('FS:---> setVolume ');
    await _waitOpen();
    if (!_isInited) {
      throw Exception('Player is not open');
    }
    //var indexedVolume = (!kIsWeb) && Platform.isIOS ? volume * 100 : volume;
    if (volume < 0.0 || volume > 1.0) {
      throw RangeError('Value of volume should be between 0.0 and 1.0.');
    }

    var state = await TauPlayerPlatform.instance.setVolume(
      this,
      volume: volume,
    );
    _playerState = PlayerState.values[state];
    _playerStateController?.add(_playerState);
    _logger.d('FS:<--- setVolume ');
  }

  Future<void> _setSpeed(double speed) async {
    _logger.d('FS:---> _setSpeed ');
    await _waitOpen();
    if (!_isInited) {
      throw Exception('Player is not open');
    }
    if (speed < 0.0) {
      throw RangeError('Value of speed should be between 0.0 and n.');
    }

    var state = await TauPlayerPlatform.instance.setSpeed(
      this,
      speed: speed,
    );
    _playerState = PlayerState.values[state];
    _playerStateController?.add(_playerState);
    _logger.d('FS:<--- _setSpeed ');
  }

  Future<void> _feedFromStream(Uint8List buffer) async {
    var lnData = 0;
    var totalLength = buffer.length;
    while (totalLength > 0 && !isStopped) {
      var bsize = totalLength > _blockSize ? _blockSize : totalLength;
      var ln = await _feed(buffer.sublist(lnData, lnData + bsize));
      assert(ln >= 0);
      lnData += ln;
      totalLength -= ln;
    }
  }

  ///
  Future<int> _feed(Uint8List data) async {
    await _waitOpen();
    if (!_isInited) {
      throw Exception('Player is not open');
    }
    if (isStopped) {
      return 0;
    }
    _needSomeFoodCompleter = Completer<int>();
    try {
      var ln = await (TauPlayerPlatform.instance.feed(
        this,
        data: data,
      ));
      assert(ln >= 0); // feedFromStream() is not happy if < 0
      if (ln != 0) {
        _needSomeFoodCompleter = null;
        return (ln);
      }
    } on Exception {
      _needSomeFoodCompleter = null;
      if (isStopped) {
        return 0;
      }
      rethrow;
    }

    if (_needSomeFoodCompleter != null) {
      return _needSomeFoodCompleter!.future;
    }
    return 0;
  }

  //===================================  Callbacks ================================================================

  /// Completers
  Completer<int>? _needSomeFoodCompleter;
  Completer<Duration>? _startPlayerCompleter;
  Completer<void>? _pausePlayerCompleter;
  Completer<void>? _resumePlayerCompleter;
  Completer<void>? _stopPlayerCompleter;
  Completer<void>? _closePlayerCompleter;
  Completer<TauPlayer>? _openPlayerCompleter;

  /// Callback from the &tau; Core. Must not be called by the App
  /// @nodoc
  @override
  void updateProgress({
    int duration = 0,
    int position = 0,
  }) {
    if (duration < position) {
      _logger.d(' Duration = $duration,   Position = $position');
    }
    _playerController!.add(
      PlaybackDisposition(
        position: Duration(milliseconds: position),
        duration: Duration(milliseconds: duration),
      ),
    );
  }

  /// Callback from the &tau; Core. Must not be called by the App
  /// @nodoc
  @override
  void updatePlaybackState(int state) {
    if (state >= 0 && state < PlayerState.values.length) {
      _playerState = PlayerState.values[state];
      _playerStateController?.add(_playerState);
    }
  }

  /// Callback from the &tau; Core. Must not be called by the App
  /// @nodoc
  @override
  void needSomeFood(int ln) {
    assert(ln >= 0);
    _needSomeFoodCompleter?.complete(ln);
  }

  /// Callback from the &tau; Core. Must not be called by the App
  /// @nodoc
  @override
  void audioPlayerFinished(int state) async {
    _logger.d('FS:---> audioPlayerFinished');
    //await _lock.synchronized(() async {
    //playerState = PlayerState.isStopped;
    //int state = call['arg'] as int;
    _playerState = PlayerState.values[state];
    _playerStateController?.add(_playerState);
    //await _stop(); // ??? Maybe ??? perhaps ??? //
    await stop(); // ??? Maybe ??? perhaps ??? //
    _cleanCompleters(); // We have problem when the record is finished and a resume is pending

    _audioPlayerFinishedPlaying?.call();
    //});
    _logger.d('FS:<--- audioPlayerFinished');
  }

  /// Callback from the &tau; Core. Must not be called by the App
  /// @nodoc
  @override
  void openPlayerCompleted(int state, bool success) {
    _logger.d('---> openPlayerCompleted: $success');

    _playerState = PlayerState.values[state];
    _isInited = success;
    if (_openPlayerCompleter == null) {
      _logger.e('Error : cannot process _openPlayerCompleter');
      return;
    }
    if (success) {
      _openPlayerCompleter!.complete(this);
    } else {
      _openPlayerCompleter!.completeError('openPlayer failed');
    }
    _playerStateController?.add(_playerState);
    _openPlayerCompleter = null;
    _logger.d('<--- openPlayerCompleted: $success');
  }

  /// Callback from the &tau; Core. Must not be called by the App
  /// @nodoc
  @override
  void closePlayerCompleted(int state, bool success) {
    _logger.d('---> closePlayerCompleted');
    _playerState = PlayerState.values[state];
    _isInited = false;
    if (_closePlayerCompleter == null) {
      _logger.e('Error : cannot process _closePlayerCompleter');
      return;
    }

    if (success) {
      _closePlayerCompleter!.complete(this);
    } else {
      _closePlayerCompleter!.completeError('closePlayer failed');
    }
    _closePlayerCompleter = null;

    _cleanCompleters();
    _playerStateController?.add(_playerState);
    _logger.d('<--- closePlayerCompleted');
  }

  /// Callback from the &tau; Core. Must not be called by the App
  /// @nodoc
  @override
  void pausePlayerCompleted(int state, bool success) {
    _logger.d('---> pausePlayerCompleted: $success');
    if (_pausePlayerCompleter == null) {
      _logger.e('Error : cannot process _pausePlayerCompleter');
      return;
    }
    _playerState = PlayerState.values[state];
    if (success) {
      _pausePlayerCompleter!.complete();
    } else {
      _pausePlayerCompleter!.completeError('pausePlayer failed');
    }
    _pausePlayerCompleter = null;
    _playerStateController?.add(_playerState);
    _logger.d('<--- pausePlayerCompleted: $success');
  }

  /// Callback from the &tau; Core. Must not be called by the App
  /// @nodoc
  @override
  void resumePlayerCompleted(int state, bool success) {
    _logger.d('---> resumePlayerCompleted: $success');
    if (_resumePlayerCompleter == null) {
      _logger.e('Error : cannot process _resumePlayerCompleter');
      return;
    }
    _playerState = PlayerState.values[state];
    if (success) {
      _resumePlayerCompleter!.complete();
    } else {
      _resumePlayerCompleter!.completeError('resumePlayer failed');
    }
    _resumePlayerCompleter = null;
    _playerStateController?.add(_playerState);
    _logger.d('<--- resumePlayerCompleted: $success');
  }

  /// Callback from the &tau; Core. Must not be called by the App
  /// @nodoc
  @override
  void startPlayerCompleted(int state, bool success, int duration) {
    _logger.d('---> startPlayerCompleted: $success');
    if (_startPlayerCompleter == null) {
      _logger.e('Error : cannot process _startPlayerCompleter');
      return;
    }
    _playerState = PlayerState.values[state];
    if (success) {
      _startPlayerCompleter!.complete(Duration(milliseconds: duration));
    } else {
      _startPlayerCompleter!.completeError('startPlayer() failed');
    }
    _startPlayerCompleter = null;
    _playerStateController?.add(_playerState);
    _logger.d('<--- startPlayerCompleted: $success');
  }

  /// Callback from the &tau; Core. Must not be called by the App
  /// @nodoc
  @override
  void stopPlayerCompleted(int state, bool success) {
    _logger.d('---> stopPlayerCompleted: $success');
    if (_stopPlayerCompleter == null) {
      _logger.d('Error : cannot process stopPlayerCompleted');
      _logger.d('<--- stopPlayerCompleted: $success');
      return;
    }
    _playerState = PlayerState.values[state];
    if (success) {
      _stopPlayerCompleter!.complete();
    } // stopRecorder must not gives errors
    else {
      _stopPlayerCompleter!.completeError('stopPlayer failed');
    }
    _stopPlayerCompleter = null;
    // cleanCompleters(); ????
    _playerStateController?.add(_playerState);
    _logger.d('<--- stopPlayerCompleted: $success');
  }

  void _cleanCompleters() {
    if (_pausePlayerCompleter != null) {
      var completer = _pausePlayerCompleter;
      _logger.w('Kill _pausePlayer()');
      _pausePlayerCompleter = null;
      completer!.completeError('killed by cleanCompleters');
    }

    if (_resumePlayerCompleter != null) {
      var completer = _resumePlayerCompleter;
      _logger.w('Kill _resumePlayer()');
      _resumePlayerCompleter = null;
      completer!.completeError('killed by cleanCompleters');
    }

    if (_startPlayerCompleter != null) {
      var completer = _startPlayerCompleter;
      _logger.w('Kill _startPlayer()');
      _startPlayerCompleter = null;
      completer!.completeError('killed by cleanCompleters');
    }

    if (_stopPlayerCompleter != null) {
      var completer = _stopPlayerCompleter;
      _logger.w('Kill _stopPlayer()');
      _stopPlayerCompleter = null;
      completer!.completeError('killed by cleanCompleters');
    }

    if (_openPlayerCompleter != null) {
      var completer = _openPlayerCompleter;
      _logger.w('Kill openPlayer()');
      _openPlayerCompleter = null;
      completer!.completeError('killed by cleanCompleters');
    }

    if (_closePlayerCompleter != null) {
      var completer = _closePlayerCompleter;
      _logger.w('Kill _closePlayer()');
      _closePlayerCompleter = null;
      completer!.completeError('killed by cleanCompleters');
    }
  }

  @override
  void log(Level logLevel, String msg) {
    _logger.log(logLevel, msg);
  }

  //============================================= Old API ==================================================================

  /*
  /// The Playback Controller
  StreamController<PlaybackDisposition>? _playerController;


  /// This is a stream on which FlutterSound will post the player progression.
  /// You may listen to this Stream to have feedback on the current playback.
  ///
  /// PlaybackDisposition has two fields :
  /// - Duration duration  (the total playback duration)
  /// - Duration position  (the current playback position)
  ///
  /// *Example:*
  /// ```dart
  ///         _playerSubscription = myPlayer.onProgress.listen((e)
  ///         {
  ///                 Duration maxDuration = e.duration;
  ///                 Duration position = e.position;
  ///                 ...
  ///         }
  /// ```
  Stream<PlaybackDisposition>? get onProgress =>
      _playerController != null ? _playerController!.stream : null;

  /// Provides a stream of dispositions which
  /// provide updated position and duration
  /// as the audio is played.
  ///
  /// The duration may start out as zero until the
  /// media becomes available.
  /// The `interval` dictates the minimum interval between events
  /// being sent to the stream.
  ///
  /// The minimum interval supported is 100ms.
  ///
  /// Note: the underlying stream has a minimum frequency of 100ms
  /// so multiples of 100ms will give you the most consistent timing
  /// source.
  ///
  /// Note: all calls to [dispositionStream] against this player will
  /// share a single interval which will controlled by the last
  /// call to this method.
  ///
  /// If you pause the audio then no updates will be sent to the
  /// stream.
  Stream<PlaybackDisposition>? dispositionStream() {
    return _playerController != null ? _playerController!.stream : null;
  }
*/
}

/// FoodData are the regular objects received from a recorder when recording to a Dart Stream
/// or sent to a player when playing from a Dart Stream
class TauFoodData extends TauFood {
  /// the data to be sent (or received)
  Uint8List? data;

  /// The constructor, specifying the data to be sent or that has been received
  /* ctor */ TauFoodData(this.data);

  /// Used internally by Flutter Sound
  @override
  Future<void> exec(TauPlayer player) => player.feedFromStream(data!);
}

/// foodEvent is a special kind of food which allows to re-synchronize a stream
/// with a player that play from a Dart Stream
class TauFoodEvent extends TauFood {
  /// The callback to fire when this food is synchronized with the player
  Function on;

  /// The constructor, specifying the callback which must be fired when synchronization is done
  /* ctor */ TauFoodEvent(this.on);

  /// Used internally by Flutter Sound
  @override
  Future<void> exec(TauPlayer player) async => on();
}

/// Food is an abstract class which represents objects that can be sent
/// to a player when playing data from astream or received by a recorder
/// when recording to a Dart Stream.
///
/// This class is extended by
/// - [TauFoodData] and
/// - [TauFoodEvent].
abstract class TauFood {
  /// use internally by Flutter Sound
  Future<void> exec(TauPlayer player);

  /// use internally by Flutter Sound
  void dummy(TauPlayer player) {} // Just to satisfy `dartanalyzer`

}

/// Used to stream data about the position of the
/// playback as playback proceeds.
class PlaybackDisposition {
  /// The duration of the media.
  final Duration duration;

  /// The current position within the media
  /// that we are playing.
  final Duration position;

  /// A convenience ctor. If you are using a stream builder
  /// you can use this to set initialData with both duration
  /// and postion as 0.
  PlaybackDisposition.zero()
      : position = Duration(seconds: 0),
        duration = Duration(seconds: 0);

  /// The constructor
  PlaybackDisposition({
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  ///
  @override
  String toString() {
    return 'duration: $duration, '
        'position: $position';
  }
}
