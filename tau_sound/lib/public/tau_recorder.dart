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

/// **THE** Flutter Sound Recorder
/// {@category Main}
library recorder;

import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:tau_platform_interface/tau_platform_interface.dart';
import 'package:tau_platform_interface/tau_recorder_platform_interface.dart';
import 'package:logger/logger.dart' show Level, Logger;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

import '../tau_sound.dart';
import 'util/tau_helper.dart';

/// Playback function type for [FlutterSoundPlayer.startPlayer()].
///
/// Note : this type must include a parameter with a reference to the FlutterSoundPlayer object involved.
typedef TOnRecorderProgress = void Function(
    Duration position, double dbPeakLevel);

/// A Recorder is an object that can record from various sources.
///
/// ----------------------------------------------------------------------------------------------------
///
/// Using a recorder is very simple :
///
/// 1. Create a new `TauRecorder`
///
/// 2. Open it with [open()]
///
/// 3. Start your recording with [record()].
///
/// 4. Use the various verbs (optional):
///    - [pause()]
///    - [resume()]
///    - ...
///
/// 5. Stop your recorder : [stop()]
///
/// 6. Release your recorder when you have finished with it : [close()].
/// This verb will call [stop()] if necessary.
///
/// ----------------------------------------------------------------------------------------------------
class TauRecorder implements TauRecorderCallback {
  //============================================ New API V9 ===================================================================

  /// The TauRecorder Logger getter
  Logger get logger => _logger;

  /// The current state of the Recorder
  RecorderState get recorderState => _recorderState;

  /// True if `recorderState.isRecording`
  bool get isRecording => (_recorderState == RecorderState.isRecording);

  /// True if `recorderState.isStopped`
  bool get isStopped => (_recorderState == RecorderState.isStopped);

  /// True if `recorderState.isPaused`
  bool get isPaused => (_recorderState == RecorderState.isPaused);

  /// Instanciate a new Flutter Sound Recorder.
  /// The optional paramater `Level logLevel` specify the Logger Level you are interested by.
  /* ctor */ TauRecorder({Level logLevel = Level.debug}) {
    _logger = Logger(level: logLevel);
    _logger.d('ctor: TauRecorder()');
  }

  /// Used if the App wants to dynamically change the Log Level.
  /// Seldom used. Most of the time the Log Level is specified during the constructor.
  Future<void> setLogLevel(Level aLevel) async {
    _logLevel = aLevel;
    _logger = Logger(level: aLevel);
    await _lock.synchronized(() async {
      if (_isInited) {
        await TauRecorderPlatform.instance.setLogLevel(
          this,
          aLevel,
        );
      }
    });
  }

  /// Returns true if the specified encoder is supported by flutter_sound on this platform.
  ///
  /// This verb is useful to know if a particular codec is supported on the current platform;
  /// Returns a Future<bool>.
  ///
  /// *Example:*
  /// ```dart
  ///         if ( await myRecorder.isEncoderSupported(Codec.opusOGG) ) doSomething;
  /// ```
  /// `isEncoderSupported` is a method for legacy reason, but should be a static function.
  Future<bool> isEncoderSupported(TauCodec codec) async {
    // For encoding ogg/opus on ios, we need to support two steps :
    // - encode CAF/OPPUS (with native Apple AVFoundation)
    // - remux CAF file format to OPUS file format (with ffmpeg)
    await _waitOpen();
    if (!_isInited) {
      throw Exception('Recorder is not open');
    }
    var result = false;
    // For encoding ogg/opus on ios, we need to support two steps :
    // - encode CAF/OPPUS (with native Apple AVFoundation)
    // - remux CAF file format to OPUS file format (with ffmpeg)

    if ((codec is Opus) && (!kIsWeb) && (Platform.isIOS)) {
      //if (!await isFFmpegSupported( ))
      //result = false;
      //else
      result = await TauRecorderPlatform.instance
          .isEncoderSupported(this, codec: Codec.opusCAF);
    } else {
      result = await TauRecorderPlatform.instance
          .isEncoderSupported(this, codec: codec.deprecatedCodec);
    }
    return result;
  }

  /// Return the file extension for the given path.
  /// path can be null. We return null in this case.
  String _fileExtension(String path) {
    var r = p.extension(path);
    return r;
  }

  TauCodec? _getCodecFromExtension(extension) {
    for (var codec in Codec.values) {
      if (ext[codec.index] == extension) {
        return getCodecFromDeprecated(codec);
      }
    }
    return null;
  }

  bool _isValidFileExtension(TauCodec codec, String extension) {
    var extList = validExt[(codec.deprecatedCodec).index];
    for (var s in extList) {
      if (s == extension) return true;
    }
    return false;
  }

  /// Open a Recorder
  ///
  /// A recorder must be opened before used. A recorder correspond to an Audio Session. With other words, you must *open* the Audio Session before using it.
  /// When you have finished with a Recorder, you must close it. With other words, you must close your Audio Session.
  /// Opening a recorder takes resources inside the OS. Those resources are freed with the verb `closeAudioSession()`.
  ///
  /// You MUST ensure that the recorder has been closed when your widget is detached from the UI.
  /// Overload your widget's `dispose()` method to close the recorder when your widget is disposed.
  /// In this way you will reset the Recorder and clean up the device resources, but the recorder will be no longer usable.
  ///
  /// ```dart
  /// @override
  /// void dispose()
  /// {
  ///         if (myRecorder != null)
  ///         {
  ///             myRecorder.closeAudioSession();
  ///             myRecorder = null;
  ///         }
  ///         super.dispose();
  /// }
  /// ```
  ///
  /// You may not openAudioSession many recorders without releasing them.
  ///
  /// `openAudioSession()` and `closeAudioSession()` return Futures.
  /// You do not need to wait the end of the initialization before [startRecorder()].
  /// [startRecorder] will automaticaly wait the end of `openAudioSession()` before starting the recorder.
  ///
  /// The four optional parameters are used if you want to control the Audio Focus. Please look to [TauRecorder openAudioSession()](Recorder.md#openaudiosession-and-closeaudiosession) to understand the meaning of those parameters
  ///
  /// *Example:*
  /// ```dart
  ///     myRecorder = await TauRecorder().openAudioSession();
  ///
  ///     ...
  ///     (do something with myRecorder)
  ///     ...
  ///
  ///     myRecorder.closeAudioSession();
  ///     myRecorder = null;
  /// ```
  Future<TauRecorder?> open({
    required InputDeviceNode from,
    required OutputNode to,
  }) async {
    if (_isInited) {
      return this;
    }

    TauRecorder? r;
    _logger.d('FS:---> open ');
    await _lock.synchronized(() async {
      r = await _open(from: from, to: to);
    });
    _logger.d('FS:<--- open ');
    return r;
  }

  /// Close a Recorder
  ///
  /// You must close your recorder when you have finished with it, for releasing the resources.
  /// Delete all the temporary files created with `startRecorder()`

  Future<void> close() async {
    _logger.d('FS:---> close ');
    await _lock.synchronized(() async {
      await _close();
    });
    _logger.d('FS:<--- close ');
  }

  /// `startRecorder()` starts recording with an open session.
  ///
  /// If an [openAudioSession()] is in progress, `startRecorder()` will automatically wait the end of the opening.
  /// `startRecorder()` has the destination file path as parameter.
  /// It has also 7 optional parameters to specify :
  /// - codec: The codec to be used. Please refer to the [Codec compatibility Table](codec.md#actually-the-following-codecs-are-supported-by-flutter_sound) to know which codecs are currently supported.
  /// - toFile: a path to the file being recorded or the name of a temporary file (without slash '/').
  /// - toStream: if you want to record to a Dart Stream. Please look to [the following notice](codec.md#recording-pcm-16-to-a-dart-stream). **This new functionnality needs, at least, Android SDK >= 21 (23 is better)**
  /// - sampleRate: The sample rate in Hertz
  /// - numChannels: The number of channels (1=monophony, 2=stereophony)
  /// - bitRate: The bit rate in Hertz
  /// - audioSource : possible value is :
  ///    - defaultSource
  ///    - microphone
  ///    - voiceDownlink *(if someone can explain me what it is, I will be grateful ;-) )*
  ///
  /// [path_provider](https://pub.dev/packages/path_provider) can be useful if you want to get access to some directories on your device.
  /// To record a temporary file, the App can specify the name of this temporary file (without slash) instead of a real path.
  ///
  /// Flutter Sound does not take care of the recording permission. It is the App responsability to check or require the Recording permission.
  /// [Permission_handler](https://pub.dev/packages/permission_handler) is probably useful to do that.
  ///
  /// *Example:*
  /// ```dart
  ///     // Request Microphone permission if needed
  ///     PermissionStatus status = await Permission.microphone.request();
  ///     if (status != PermissionStatus.granted)
  ///             throw RecordingPermissionException("Microphone permission not granted");
  ///
  ///     await myRecorder.startRecorder(toFile: 'foo', codec: t_CODEC.CODEC_AAC,); // A temporary file named 'foo'
  /// ```
  Future<void> record({
    TOnRecorderProgress? onProgress,
    Duration? interval,
  }) async {
    _logger.d('FS:---> record ');
    await _lock.synchronized(() async {
      await _startRecorder(onProgress: onProgress, interval: interval);
    });
    _logger.d('FS:<--- record ');
  }

  /// Stop a record.
  ///
  /// Return a Future to an URL of the recorded sound.
  ///
  /// *Example:*
  /// ```dart
  ///         String anURL = await myRecorder.stopRecorder();
  ///         if (_recorderSubscription != null)
  ///         {
  ///                 _recorderSubscription.cancel();
  ///                 _recorderSubscription = null;
  ///         }
  /// }
  /// ```
  Future<void> stop() async {
    _logger.d('FS:---> stopRecorder ');
    await _lock.synchronized(() async {
      await _stopRecorder();
    });
    _logger.d('FS:<--- stopRecorder ');
  }

  /// Pause the recorder
  ///
  /// On Android this API verb needs al least SDK-24.
  /// An exception is thrown if the Recorder is not currently recording.
  ///
  /// *Example:*
  /// ```dart
  /// await myRecorder.pauseRecorder();
  /// ```
  Future<void> pause() async {
    _logger.d('FS:---> pauseRecorder ');
    await _lock.synchronized(() async {
      await _pauseRecorder();
    });
    _logger.d('FS:<--- pauseRecorder ');
  }

  /// Resume a paused Recorder
  ///
  /// On Android this API verb needs al least SDK-24.
  /// An exception is thrown if the Recorder is not currently paused.
  ///
  /// *Example:*
  /// ```dart
  /// await myRecorder.resumeRecorder();
  /// ```
  Future<void> resume() async {
    _logger.d('FS:---> pausePlayer ');
    await _lock.synchronized(() async {
      await _resumeRecorder();
    });
    _logger.d('FS:<--- resumeRecorder ');
  }

  /// Delete a temporary file
  ///
  /// Delete a temporary file created during [startRecorder()].
  /// the argument must be a file name without any path.
  /// This function is seldom used, because [closeAudioSession()] delete automaticaly
  /// all the temporary files created.
  ///
  /// *Example:*
  /// ```dart
  ///      await myRecorder.startRecorder(toFile: 'foo'); // This is a temporary file, because no slash '/' in the argument
  ///      await myPlayer.startPlayer(fromURI: 'foo');
  ///      await myRecorder.deleteRecord('foo');
  /// ```
  Future<bool?> deleteRecord({required String fileName}) async {
    _logger.d('FS:---> deleteRecord');
    await _waitOpen();
    if (!_isInited) {
      throw Exception('Recorder is not open');
    }
    var b = await TauRecorderPlatform.instance.deleteRecord(this, fileName);
    _logger.d('FS:<--- deleteRecord');
    return b;
  }

  /// Get the URI of a recorded file.
  ///
  /// This is same as the result of [stopRecorder()].
  /// Be careful : on Flutter Web, this verb cannot be used before stoping
  /// the recorder.
  /// This verb is seldom used. Most of the time, the App will use the result
  /// of [stopRecorder()].
  Future<String?> getRecordURL({required String path}) async {
    await _waitOpen();
    if (!_isInited) {
      throw Exception('Recorder is not open');
    }
    var url = await TauRecorderPlatform.instance.getRecordURL(this, path);
    return url;
  }

  //--------------------------------------------- Locals --------------------------------------------------------------------

  /// Locals
  /// ------
  ///
  ///

  /// The TauRecorder Logger
  Logger _logger = Logger(level: Level.debug);
  Level _logLevel = Level.debug;

  final _lock = Lock();
  //static bool _reStarted = true;

  bool _isInited = false;
  bool _isOggOpus =
      false; // Set by startRecorder when the user wants to record an ogg/opus

  String?
      _savedUri; // Used by startRecorder/stopRecorder to keep the caller wanted uri

  String?
      _tmpUri; // Used by startRecorder/stopRecorder to keep the temporary uri to record CAF

  RecorderState _recorderState = RecorderState.isStopped;
  InputDeviceNode? _from;
  OutputNode? _to;

  /// A reference to the User Sink during `StartRecorder(toStream:...)`
  StreamSink<TauFood>? _userStreamSink;
  TOnRecorderProgress? _onProgress;

  Future<void> _waitOpen() async {
    while (_openRecorderCompleter != null) {
      _logger.w('Waiting for the recorder being opened');
      await _openRecorderCompleter!.future;
    }
    if (!_isInited) {
      throw Exception('Recorder is not open');
    }
  }

  Future<TauRecorder> _open({
    required InputDeviceNode from,
    required OutputNode to,
  }) async {
    _logger.d('---> openAudioSession');

    Completer<TauRecorder>? completer;
    if (_isInited) {
      throw Exception('Recorder is already open');
    }

    if (_userStreamSink != null) {
      await _userStreamSink!.close();
      _userStreamSink = null;
    }
    assert(_openRecorderCompleter == null);
    _openRecorderCompleter = Completer<TauRecorder>();
    completer = _openRecorderCompleter;
    try {
      //if (_reStarted) {
      // Perhaps a Hot Restart ?  We must reset the plugin
      //_logger.d('Resetting flutter_sound Recorder Plugin');
      // _reStarted = false;
      // await FlutterSoundRecorderPlatform.instance.resetPlugin(this);
      //}

      TauRecorderPlatform.instance.openSession(this);
      await TauRecorderPlatform.instance.openRecorder(
        this,
        logLevel: _logLevel,
        focus: AudioFocus.doNotRequestFocus,
        category: SessionCategory.playAndRecord,
        mode: SessionMode.modeDefault,
        audioFlags: 0,
        device: AudioDevice.obsolete,
      );
      _from = from;
      _to = to;
    } on Exception {
      _openRecorderCompleter = null;
      rethrow;
    }
    _logger.d('<--- openAudioSession');
    return completer!.future;
  }

  Future<void> _close() async {
    _logger.d('FS:---> closeAudioSession ');
    // If another closeRecorder() is already in progress, wait until finished
    while (_closeRecorderCompleter != null) {
      try {
        _logger.w('Another closeRecorder() in progress');
        await _closeRecorderCompleter!.future;
      } catch (_) {}
    }
    if (!_isInited) {
      // Already close
      _logger.i('Recorder already close');
      return;
    }

    Completer<void>? completer;

    try {
      await _stop(); // Stop the recorder if running
    } catch (e) {
      _logger.e(e.toString());
    }
    if (_userStreamSink != null) {
      await _userStreamSink!.close();
      _userStreamSink = null;
    }
    assert(_closeRecorderCompleter == null);
    _closeRecorderCompleter = Completer<void>();
    try {
      completer = _closeRecorderCompleter;

      await TauRecorderPlatform.instance.closeRecorder(this);
      TauRecorderPlatform.instance.closeSession(this);
    } on Exception {
      _closeRecorderCompleter = null;
      rethrow;
    }
    _logger.d('FS:<--- closeAudioSession ');
    return completer!.future;
  }

  Future<void> _startRecorderToURI(
      InputDeviceNode from, OutputFileNode outputFile) async {
    var path = outputFile.uri;
    var codec = outputFile.codec;
    var extension = _fileExtension(
      outputFile.uri,
    );
    if (codec is DefaultCodec) {
      var codecExt = _getCodecFromExtension(extension);
      if (codecExt == null) {
        throw _CodecNotSupportedException(
            "File extension '$extension' not recognized.");
      }
      codec = codecExt;
    }
    if (!_isValidFileExtension(codec, extension)) {
      throw _CodecNotSupportedException(
          "File extension '$extension' is incorrect for the audio codec '$codec'");
    }

    if (!await (isEncoderSupported(codec))) {
      throw _CodecNotSupportedException('Codec not supported.');
    }

    if ((!kIsWeb) && (Platform.isIOS)) {
      if ((codec is Opus && codec.audioFormat == AudioFormat.ogg) ||
          _fileExtension(path) == '.opus') {
        _savedUri = path;
        _isOggOpus = true;
        codec = Opus(AudioFormat.caf);
        var tempDir = await getTemporaryDirectory();
        var fout = File('${tempDir.path}/flutter_sound-tmp.caf');
        path = fout.path;
        _tmpUri = path;
      }
    }

    if (codec is Pcm) {
      var c = codec;
      await TauRecorderPlatform.instance.startRecorder(
        this,
        path: path,
        codec: codec.deprecatedCodec,
        toStream: false,
        audioSource: from.audioSource,
        sampleRate: c.sampleRate,
        numChannels: c.nbrChannels(),
      );
    } else {
      await TauRecorderPlatform.instance.startRecorder(
        this,
        path: path,
        codec: codec.deprecatedCodec,
        toStream: false,
        audioSource: from.audioSource,
      );
    }
  }

  Future<void> _startRecorderToBuffer(
      InputDeviceNode from, OutputBufferNode outputBuffer) async {
// Unimplemented
  }

  Future<void> _startRecorderToStream(
      InputDeviceNode from, OutputStreamNode outputStream) async {
    _userStreamSink = outputStream.stream;
    var c = outputStream.getPcmCodec();
    if (c == null) {
      throw Exception('Output PCM is undefined');
    }
    var codec = c;
    await TauRecorderPlatform.instance.startRecorder(
      this,
      path: null,
      codec: outputStream.codec.deprecatedCodec,
      toStream: true,
      audioSource: from.audioSource,
      numChannels: codec.nbrChannels(),
      sampleRate: codec.sampleRate,
    );
  }

  Future<void> _startRecorder({
    TOnRecorderProgress? onProgress,
    Duration? interval,
  }) async {
    _logger.d('FS:---> _startRecorder.');
    await _waitOpen();
    if (!_isInited) {
      throw Exception('Recorder is not open');
    }
    await _stop();
    if ((onProgress != null && interval == null) ||
        (onProgress == null && interval != null)) {
      throw (Exception(
          'You must specify both the `onProgress` and the `interval` parameters'));
    }

    //var codec = to.codec;

    Completer<void>? completer;
    // Maybe we should stop any recording already running... (stopRecorder does that)

    // If we want to record OGG/OPUS on iOS, we record with CAF/OPUS and we remux the CAF file format to a regular OGG/OPUS.
    // We use FFmpeg for that task.
    _isOggOpus = false;
    _userStreamSink = null;
    if (_startRecorderCompleter != null) {
      _logger.w('Killing another startRecorder()');
      _startRecorderCompleter!
          .completeError('Killed by another startRecorder()');
    }

    try {
      _startRecorderCompleter = Completer<void>();
      completer = _startRecorderCompleter;

      _onProgress = onProgress;
      if (_onProgress != null) {
        await TauRecorderPlatform.instance
            .setSubscriptionDuration(this, duration: interval);
      }
      switch (_to.runtimeType) {
        case OutputFileNode:
          await _startRecorderToURI(_from!, _to as OutputFileNode);
          break;
        case OutputBufferNode:
          await _startRecorderToBuffer(_from!, _to as OutputBufferNode);
          break;
        case OutputStreamNode:
          await _startRecorderToStream(_from!, _to as OutputStreamNode);
          break;
      }

      _recorderState = RecorderState.isRecording;
    } on Exception {
      _startRecorderCompleter = null;
      rethrow;
    }
    _logger.d('FS:<--- _startRecorder.');
    return completer!.future;
  }

  Future<String> _stop() async {
    _logger.d('FS:---> _stop');
    _onProgress = null;
    _stopRecorderCompleter = Completer<String>();
    var completer = _stopRecorderCompleter!;
    try {
      await TauRecorderPlatform.instance.stopRecorder(this);
      _userStreamSink = null;

      _recorderState = RecorderState.isStopped;
    } on Exception {
      _stopRecorderCompleter = null;
      rethrow;
    }

    _logger.d('FS:<--- _stop');
    return completer.future;
  }

  Future<String> _stopRecorder() async {
    _logger.d('FS:---> _stopRecorder ');
    while (_openRecorderCompleter != null) {
      _logger.w('Waiting for the recorder being opened');
      await _openRecorderCompleter!.future;
    }
    if (!_isInited) {
      _logger.d('<--- _stopRecorder : Recorder is not open');
      return '';
    }
    var r = '';

    try {
      r = await _stop();

      if (_isOggOpus) {
        // delete the target if it exists
        // (ffmpeg gives an error if the output file already exists)
        var f = File(_savedUri!);
        if (f.existsSync()) {
          await f.delete();
        }
        // The following ffmpeg instruction re-encode the Apple CAF to OPUS.
        // Unfortunately we cannot just remix the OPUS data,
        // because Apple does not set the "extradata" in its private OPUS format.
        // It will be good if we can improve this...
        var rc = await TauHelper().executeFFmpegWithArguments([
          '-loglevel',
          'error',
          '-y',
          '-i',
          _tmpUri,
          '-c:a',
          'libopus',
          _savedUri,
        ]); // remux CAF to OGG
        if (rc != 0) {
          return '';
        }
        r = _savedUri!;
      }
    } on Exception catch (e) {
      _logger.e(e);
    }
    _logger.d('FS:<--- _stopRecorder : $r');
    return r;
  }

  Future<void> _pauseRecorder() async {
    _logger.d('FS:---> pauseRecorder');
    await _waitOpen();
    if (!_isInited) {
      throw Exception('Recorder is not open');
    }
    Completer<void>? completer;
    try {
      if (_pauseRecorderCompleter != null) {
        _pauseRecorderCompleter!
            .completeError('Killed by another pauseRecorder()');
      }
      _pauseRecorderCompleter = Completer<void>();
      completer = _pauseRecorderCompleter;
      await TauRecorderPlatform.instance.pauseRecorder(this);
    } on Exception {
      _pauseRecorderCompleter = null;
      rethrow;
    }
    _recorderState = RecorderState.isPaused;
    _logger.d('FS:<--- pauseRecorder');
    return completer!.future;
  }

  Future<void> _resumeRecorder() async {
    _logger.d('FS:---> resumeRecorder ');
    await _waitOpen();
    if (!_isInited) {
      throw Exception('Recorder is not open');
    }
    Completer<void>? completer;
    try {
      if (_resumeRecorderCompleter != null) {
        _resumeRecorderCompleter!
            .completeError('Killed by another resumeRecorder()');
      }
      _resumeRecorderCompleter = Completer<void>();
      completer = _resumeRecorderCompleter;
      await TauRecorderPlatform.instance.resumeRecorder(this);
    } on Exception {
      _resumeRecorderCompleter = null;
      rethrow;
    }
    _recorderState = RecorderState.isRecording;
    _logger.d('FS:<--- resumeRecorder ');
    return completer!.future;
  }

  //===================================  Callbacks ================================================================

  /// Completers

  Completer<void>? _startRecorderCompleter;
  Completer<void>? _pauseRecorderCompleter;
  Completer<void>? _resumeRecorderCompleter;
  Completer<String>? _stopRecorderCompleter;
  Completer<void>? _closeRecorderCompleter;
  Completer<TauRecorder>? _openRecorderCompleter;

  /// Callback from the &tau; Core. Must not be called by the App
  /// @nodoc
  @override
  void recordingData({Uint8List? data}) {
    if (_userStreamSink != null) {
      //Uint8List data = call['recordingData'] as Uint8List;
      _userStreamSink!.add(TauFoodData(data));
    }
  }

  /// Callback from the &tau; Core. Must not be called by the App
  /// @nodoc
  @override
  void updateRecorderProgress(
      {required int duration, required double dbPeakLevel}) {
    if (_onProgress != null) {
      _onProgress!(Duration(milliseconds: duration), dbPeakLevel);
    }
  }

  /// Callback from the &tau; Core. Must not be called by the App
  /// @nodoc
  @override
  void openRecorderCompleted(int? state, bool? success) {
    _logger.d('---> openRecorderCompleted: $success');

    _recorderState = RecorderState.values[state!];
    _isInited = success ?? false;
    if (_isInited) {
      _openRecorderCompleter!.complete(this);
    } else {
      _pauseRecorderCompleter!.completeError('openRecorder failed');
    }
    _openRecorderCompleter = null;
    _logger.d('<--- openRecorderCompleted: $success');
  }

  /// Callback from the &tau; Core. Must not be called by the App
  /// @nodoc
  @override
  void closeRecorderCompleted(int? state, bool? success) {
    _logger.d('---> closeRecorderCompleted');
    _recorderState = RecorderState.values[state!];
    _isInited = false;
    _closeRecorderCompleter!.complete();
    _closeRecorderCompleter = null;
    _cleanCompleters();
    _logger.d('<--- closeRecorderCompleted');
  }

  /// Callback from the &tau; Core. Must not be called by the App
  /// @nodoc
  @override
  void pauseRecorderCompleted(int? state, bool? success) {
    _logger.d('---> pauseRecorderCompleted: $success');
    assert(state != null);
    _recorderState = RecorderState.values[state!];
    if (success!) {
      _pauseRecorderCompleter!.complete();
    } else {
      _pauseRecorderCompleter!.completeError('pauseRecorder failed');
    }
    _pauseRecorderCompleter = null;
    _logger.d('<--- pauseRecorderCompleted: $success');
  }

  /// Callback from the &tau; Core. Must not be called by the App
  /// @nodoc
  @override
  void resumeRecorderCompleted(int? state, bool? success) {
    _logger.d('---> resumeRecorderCompleted: $success');
    assert(state != null);
    _recorderState = RecorderState.values[state!];
    if (success!) {
      _resumeRecorderCompleter!.complete();
    } else {
      _resumeRecorderCompleter!.completeError('resumeRecorder failed');
    }
    _resumeRecorderCompleter = null;
    _logger.d('<--- resumeRecorderCompleted: $success');
  }

  /// Callback from the &tau; Core. Must not be called by the App
  /// @nodoc
  @override
  void startRecorderCompleted(int? state, bool? success) {
    _logger.d('---> startRecorderCompleted: $success');
    assert(state != null);
    _recorderState = RecorderState.values[state!];
    if (success!) {
      _startRecorderCompleter!.complete();
    } else {
      _startRecorderCompleter!.completeError('startRecorder() failed');
    }
    _startRecorderCompleter = null;
    _logger.d('<--- startRecorderCompleted: $success');
  }

  /// Callback from the &tau; Core. Must not be called by the App
  /// @nodoc
  @override
  void stopRecorderCompleted(int? state, bool? success, String? url) {
    _logger.d('---> stopRecorderCompleted: $success');
    assert(state != null);
    _recorderState = RecorderState.values[state!];
    var s = url ?? '';
    if (success!) {
      _stopRecorderCompleter!.complete(s);
    } // stopRecorder must not gives errors
    else {
      _stopRecorderCompleter!.completeError('stopRecorder failed');
    }
    _stopRecorderCompleter = null;
    // _cleanCompleters(); ????
    _logger.d('<---- stopRecorderCompleted: $success');
  }

  void _cleanCompleters() {
    if (_pauseRecorderCompleter != null) {
      _logger.w('Kill _pauseRecorder()');
      var completer = _pauseRecorderCompleter!;
      _pauseRecorderCompleter = null;
      completer.completeError('killed by cleanCompleters');
    }
    if (_resumeRecorderCompleter != null) {
      _logger.w('Kill _resumeRecorder()');
      var completer = _resumeRecorderCompleter!;
      _resumeRecorderCompleter = null;
      completer.completeError('killed by cleanCompleters');
    }

    if (_startRecorderCompleter != null) {
      _logger.w('Kill _startRecorder()');
      var completer = _startRecorderCompleter!;
      _startRecorderCompleter = null;
      completer.completeError('killed by cleanCompleters');
    }

    if (_stopRecorderCompleter != null) {
      _logger.w('Kill _stopRecorder()');
      Completer<void> completer = _stopRecorderCompleter!;
      _stopRecorderCompleter = null;
      completer.completeError('killed by cleanCompleters');
    }

    if (_openRecorderCompleter != null) {
      _logger.w('Kill openRecorder()');
      Completer<void> completer = _openRecorderCompleter!;
      _openRecorderCompleter = null;
      completer.completeError('killed by cleanCompleters');
    }

    if (_closeRecorderCompleter != null) {
      _logger.w('Kill _closeRecorder()');
      var completer = _closeRecorderCompleter!;
      _closeRecorderCompleter = null;
      completer.completeError('killed by cleanCompleters');
    }
  }

  @override
  void log(Level logLevel, String msg) {
    _logger.log(logLevel, msg);
  }
}

class _RecorderException implements Exception {
  final String _message;

  _RecorderException(this._message);

  String get message => _message;
}

class _CodecNotSupportedException extends _RecorderException {
  _CodecNotSupportedException(String message) : super(message);
}

/// Permission to record was not granted
class RecordingPermissionException extends _RecorderException {
  ///  Permission to record was not granted
  RecordingPermissionException(String message) : super(message);
}
