

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

import 'dart:async';

import 'package:logger/logger.dart' show Level , Logger;
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel_tau_recorder.dart';
import 'tau_platform_interface.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:io' show Platform;
import 'dart:typed_data' show Uint8List;



enum RecorderState {
  isStopped,
  isPaused,
  isRecording,
}

enum AudioSource {
  defaultSource,
  microphone,
  voiceDownlink, // (it does not work, at least on Android. Probably problems with the authorization )
  camCorder,
  remote_submix,
  unprocessed,
  voice_call,
  voice_communication,
  voice_performance,
  voice_recognition,
  voiceUpLink,// (it does not work, at least on Android. Probably problems with the authorization )
  bluetoothHFP,
  headsetMic,
  lineIn,
}


abstract class TauRecorderCallback
{
  void updateRecorderProgress({required int duration, required double dbPeakLevel});
  void recordingData({Uint8List? data} );
  void startRecorderCompleted(int? state, bool? success);
  void pauseRecorderCompleted(int? state, bool? success);
  void resumeRecorderCompleted(int? state, bool? success);
  void stopRecorderCompleted(int? state, bool? success, String? url);
  void openRecorderCompleted(int? state, bool? success);
  void closeRecorderCompleted(int? state, bool? success);
  void log(Level logLevel, String msg);

}


/// The interface that implementations of url_launcher must implement.
///
/// Platform implementations should extend this class rather than implement it as `url_launcher`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [TauPlatform] methods.
abstract class TauRecorderPlatform extends PlatformInterface {

  /// Constructs a UrlLauncherPlatform.
  TauRecorderPlatform() : super(token: _token);

  static final Object _token = Object();

  static TauRecorderPlatform _instance = MethodChannelTauRecorder();

  /// The default instance of [TauRecorderPlatform] to use.
  ///
  /// Defaults to [MethodChannelTauRecorder].
  static TauRecorderPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [UrlLauncherPlatform] when they register themselves.
  static set instance(TauRecorderPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }



  List<TauRecorderCallback?> _slots = [];

  @override
  int findSession(TauRecorderCallback aSession)
  {
    for (var i = 0; i < _slots.length; ++i)
    {
      if (_slots[i] == aSession)
      {
        return i;
      }
    }
    return -1;
  }

  @override
  void openSession(TauRecorderCallback aSession)
  {
    assert(findSession(aSession) == -1);

    for (var i = 0; i < _slots.length; ++i)
    {
      if (_slots[i] == null)
      {
        _slots[i] = aSession;
        return;
      }
    }
    _slots.add(aSession);
  }

  @override
  void closeSession(TauRecorderCallback aSession)
  {
    _slots[findSession(aSession)] = null;
  }

  TauRecorderCallback? getSession(int slotno)
  {
    return _slots[slotno];
  }


  int numberOfOpenSessions()
  {
    var n = 0;
    for (var i = 0; i < _slots.length; ++i)
    {
      if (_slots[i] != null)
      {
        ++n;
      }
    }
    return n;
  }



  Future<void>?   setLogLevel(TauRecorderCallback callback, Level loglevel)
  {
    throw UnimplementedError('setLogLeve() has not been implemented.');
  }


  Future<void>?   resetPlugin(TauRecorderCallback callback,)
  {
    throw UnimplementedError('resetPlugin() has not been implemented.');
  }


  Future<void> openRecorder(TauRecorderCallback callback, {required Level logLevel, AudioFocus? focus, SessionCategory? category, SessionMode? mode, int? audioFlags, AudioDevice? device})
  {
    throw UnimplementedError('openRecorder() has not been implemented.');
  }

  Future<void> closeRecorder(TauRecorderCallback callback, )
  {
    throw UnimplementedError('closeRecorder() has not been implemented.');
  }

  Future<void> setAudioFocus(TauRecorderCallback callback, {AudioFocus? focus, SessionCategory? category, SessionMode? mode, int? audioFlags, AudioDevice? device,} )
  {
    throw UnimplementedError('setAudioFocus() has not been implemented.');
  }

  Future<bool> isEncoderSupported(TauRecorderCallback callback, {required Codec codec ,})
  {
    throw UnimplementedError('isEncoderSupported() has not been implemented.');
  }

  Future<void> setSubscriptionDuration(TauRecorderCallback callback, { Duration? duration,})
  {
    throw UnimplementedError('setSubscriptionDuration() has not been implemented.');
  }

  Future<void> startRecorder(TauRecorderCallback callback,
  {
  String? path,
  int? sampleRate,
  int? numChannels,
  int? bitRate,
  Codec? codec,
  bool? toStream,
  AudioSource? audioSource,
  })
  {
    throw UnimplementedError('startRecorder() has not been implemented.');
  }

  Future<void> stopRecorder(TauRecorderCallback callback, )
  {
    throw UnimplementedError('stopRecorder() has not been implemented.');
  }

  Future<void> pauseRecorder(TauRecorderCallback callback, )
  {
    throw UnimplementedError('pauseRecorder() has not been implemented.');
  }

  Future<void> resumeRecorder(TauRecorderCallback callback, )
  {
    throw UnimplementedError('resumeRecorder() has not been implemented.');
  }

  Future<bool?> deleteRecord(TauRecorderCallback callback, String path)
  {
    throw UnimplementedError('deleteRecord() has not been implemented.');
  }

  Future<String?> getRecordURL(TauRecorderCallback callback, String path )
  {
    throw UnimplementedError('getRecordURL() has not been implemented.');
  }


}