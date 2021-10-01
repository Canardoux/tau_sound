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

import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data' show Uint8List;

import 'method_channel_tau_player.dart';
import 'tau_platform_interface.dart';

abstract class TauPlayerCallback
{

  void updateProgress({int duration, int position,}) ;
  void pauseCallback(int state);
  void resumeCallback(int state);
  void skipBackward(int state);
  void skipForward(int state);
  void updatePlaybackState(int state);
  void needSomeFood(int ln);
  void audioPlayerFinished(int state);
  void startPlayerCompleted(int state, bool success, int duration);
  void pausePlayerCompleted(int state, bool success);
  void resumePlayerCompleted(int state, bool success);
  void stopPlayerCompleted(int state, bool success);
  void openPlayerCompleted(int state, bool success);
  void closePlayerCompleted(int state, bool success);
  void log(Level logLevel, String msg);

}

/// The interface that implementations of flutter_soundPlayer must implement.
///
/// Platform implementations should extend this class rather than implement it as `url_launcher`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [TauPlayerPlatform] methods.



abstract class TauPlayerPlatform extends PlatformInterface {

  /// Constructs a UrlLauncherPlatform.
  TauPlayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static TauPlayerPlatform _instance = MethodChannelTauPlayer();

  /// The default instance of [TauPlayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelTauPlayer].
  static TauPlayerPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [MethodChannelTauPlayer] when they register themselves.
  static set instance(TauPlayerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }


  List<TauPlayerCallback?> _slots = [];

  int findSession(TauPlayerCallback aSession)
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

  void openSession(TauPlayerCallback aSession,)
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

  void closeSession(TauPlayerCallback aSession)
  {
    _slots[findSession(aSession)] = null;
  }

  TauPlayerCallback getSession(int slotno)
  {
    TauPlayerCallback? cb = _slots[slotno];
    if (cb == null)
      throw Exception('Cannot find session');
    else
      return cb;
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

  //===================================================================================================================================================

  Future<void>?   setLogLevel(TauPlayerCallback callback, Level loglevel)
  {
    throw UnimplementedError('setLogLeve() has not been implemented.');
  }

  Future<void>?   resetPlugin(TauPlayerCallback callback)
  {
    throw UnimplementedError('resetPlugin() has not been implemented.');
  }

  Future<int> openPlayer(TauPlayerCallback callback, {required Level logLevel, AudioFocus? focus, SessionCategory? category, SessionMode? mode, int? audioFlags, AudioDevice? device, bool? withUI,})
  {
    throw UnimplementedError('openPlayer() has not been implemented.');
  }

  Future<int> setAudioFocus(TauPlayerCallback callback, {AudioFocus? focus, SessionCategory? category, SessionMode? mode, int? audioFlags, AudioDevice? device,} )
  {
    throw UnimplementedError('setAudioFocus() has not been implemented.');
  }

  Future<int> closePlayer(TauPlayerCallback callback, )
  {
    throw UnimplementedError('closePlayer() has not been implemented.');
  }

  Future<int> getPlayerState(TauPlayerCallback callback, )
  {
    throw UnimplementedError('getPlayerState() has not been implemented.');
  }

  Future<Map<String, Duration>> getProgress(TauPlayerCallback callback, )
  {
    throw UnimplementedError('getProgress() has not been implemented.');
  }

  Future<bool> isDecoderSupported(TauPlayerCallback callback, { required Codec codec} )
  {
    throw UnimplementedError('isDecoderSupported() has not been implemented.');
  }

  Future<int> setSubscriptionDuration(TauPlayerCallback callback, {Duration? duration})
  {
    throw UnimplementedError('setSubscriptionDuration() has not been implemented.');
  }

  Future<int> startPlayer(TauPlayerCallback callback, {Codec? codec, Uint8List? fromDataBuffer, String?  fromURI, int? numChannels, int? sampleRate})
  {
    throw UnimplementedError('startPlayer() has not been implemented.');
  }

  Future<int> startPlayerFromMic(TauPlayerCallback callback, {int? numChannels, int? sampleRate})
  {
    throw UnimplementedError('startPlayerFromMic() has not been implemented.');
  }

  Future<int> feed(TauPlayerCallback callback, {Uint8List? data, })
  {
    throw UnimplementedError('feed() has not been implemented.');
  }

  Future<int> startPlayerFromTrack(TauPlayerCallback callback, {Duration? progress, Duration? duration, Map<String, dynamic>? track, bool? canPause, bool? canSkipForward, bool? canSkipBackward, bool? defaultPauseResume, bool? removeUIWhenStopped })
  {
    throw UnimplementedError('startPlayerFromTrack() has not been implemented.');
  }

  Future<int> nowPlaying(TauPlayerCallback callback, {Duration? progress, Duration? duration, Map<String, dynamic>? track, bool? canPause, bool? canSkipForward, bool? canSkipBackward, bool? defaultPauseResume,})
  {
    throw UnimplementedError('invokeMethod() has not been implemented.');
  }

  Future<int> stopPlayer(TauPlayerCallback callback,  )
  {
    throw UnimplementedError('invokeMethod() has not been implemented.');
  }

  Future<int> pausePlayer(TauPlayerCallback callback,  )
  {
    throw UnimplementedError('invokeMethod() has not been implemented.');
  }

  Future<int> resumePlayer(TauPlayerCallback callback,  )
  {
    throw UnimplementedError('invokeMethod() has not been implemented.');
  }

  Future<int> seekToPlayer(TauPlayerCallback callback, {Duration? duration})
  {
    throw UnimplementedError('invokeMethod() has not been implemented.');
  }

  Future<int> setVolume(TauPlayerCallback callback, {double? volume})
  {
    throw UnimplementedError('invokeMethod() has not been implemented.');
  }

  Future<int> setSpeed(TauPlayerCallback callback, {required double speed})
  {
    throw UnimplementedError('invokeMethod() has not been implemented.');
  }

  Future<int> setUIProgressBar(TauPlayerCallback callback, {Duration? duration, Duration? progress,})
  {
    throw UnimplementedError('invokeMethod() has not been implemented.');
  }

  Future<String> getResourcePath(TauPlayerCallback callback, )
  {
    throw UnimplementedError('invokeMethod() has not been implemented.');
  }

}
