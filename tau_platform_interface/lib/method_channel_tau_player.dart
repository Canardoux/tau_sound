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

import 'package:flutter/services.dart';
import 'package:logger/logger.dart' show Level , Logger;
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data' show Uint8List;

import 'tau_player_platform_interface.dart';
import 'tau_platform_interface.dart';

const MethodChannel _channel = MethodChannel('xyz.canardoux.tau_player');

/// An implementation of [FlutterSoundPlayerPlatform] that uses method channels.
class MethodChannelTauPlayer extends TauPlayerPlatform
{



  /* ctor */ MethodChannelTauPlayer()
  {
    setCallback();
  }

  void setCallback()
  {
    _channel.setMethodCallHandler((MethodCall call)
    {
      return channelMethodCallHandler(call)!;
    });
  }


  Future<dynamic>? channelMethodCallHandler(MethodCall call)
  {
    TauPlayerCallback aPlayer = getSession(call.arguments!['slotNo'] as int);
    Map arg = call.arguments ;

    bool success = call.arguments['success'] != null ? call.arguments['success'] as bool : false;
    if (arg['state'] != null)
      aPlayer.updatePlaybackState(arg['state']);

    switch (call.method)
    {
      case "updateProgress":
        {
          aPlayer.updateProgress(duration:  arg['duration'], position:  arg['position']);
        }
        break;

      case "needSomeFood":
        {
          aPlayer.needSomeFood(arg['arg']);
        }
        break;

      case "audioPlayerFinishedPlaying":
        {
          aPlayer.audioPlayerFinished(arg['arg']);
        }
        break;

      case 'pause': // Pause/Resume
        {
          aPlayer.pauseCallback(arg['arg']);
        }
        break;

        case 'resume': // Pause/Resume
        {
          aPlayer.resumeCallback(arg['arg']);
        }
        break;


      case 'skipForward':
        {
          aPlayer.skipForward(arg['arg']);
        }
        break;

      case 'skipBackward':
        {
          aPlayer.skipBackward(arg['arg']);
        }
        break;

      case 'updatePlaybackState':
        {
          aPlayer.updatePlaybackState(arg['arg']);
        }
        break;


      case 'openPlayerCompleted':
        {
          aPlayer.openPlayerCompleted(call.arguments['state'] , success);
        }
        break;




      case 'startPlayerCompleted':
        {
          int duration = arg['duration'] as int;
          aPlayer.startPlayerCompleted(call.arguments['state'], success, duration);
        }
        break;


      case "stopPlayerCompleted":
        {
          aPlayer.stopPlayerCompleted(call.arguments['state'] , success);
        }
        break;

      case "pausePlayerCompleted":
        {
          aPlayer.pausePlayerCompleted(call.arguments['state'] , success);
        }
        break;

      case "resumePlayerCompleted":
        {
          aPlayer.resumePlayerCompleted(call.arguments['state'] , success);
        }
        break;

      case "closePlayerCompleted":
        {
          aPlayer.closePlayerCompleted(call.arguments['state'], success );
        }
        break;

      case "log":
        {
          aPlayer.log(Level.values[call.arguments['level']], call.arguments['msg']);
        }
        break;


      default:
        throw ArgumentError('Unknown method ${call.method}');
    }

    return null;
  }


//===============================================================================================================================



  Future<int> invokeMethod (TauPlayerCallback callback,  String methodName, Map<String, dynamic> call) async
  {
    call['slotNo'] = findSession(callback);
    return await _channel.invokeMethod(methodName, call) as int;
  }


  Future<String> invokeMethodString (TauPlayerCallback callback, String methodName, Map<String, dynamic> call) async
  {
    call['slotNo'] = findSession(callback);
    return await _channel.invokeMethod(methodName, call) as String;
  }


  Future<bool> invokeMethodBool (TauPlayerCallback callback, String methodName, Map<String, dynamic> call) async
  {
    call['slotNo'] = findSession(callback);
    return await _channel.invokeMethod(methodName, call) as bool;
  }



  @override
  Future<void>?   setLogLevel(TauPlayerCallback callback, Level logLevel)
  {
    invokeMethod( callback, 'setLogLevel', {'logLevel': logLevel.index,});
  }


  @override
  Future<void>?   resetPlugin(TauPlayerCallback callback,)
  {
    return _channel.invokeMethod('resetPlugin', );
  }


  @override
  Future<int> openPlayer(TauPlayerCallback callback, {required Level logLevel, AudioFocus? focus, SessionCategory? category, SessionMode? mode, int? audioFlags, AudioDevice? device, bool? withUI})
  {
    return  invokeMethod( callback, 'openPlayer', {'logLevel': logLevel.index, 'focus': focus!.index, 'category': category!.index, 'mode': mode!.index, 'audioFlags': audioFlags, 'device': device!.index, 'withUI': withUI! ? 1 : 0 ,},) ;
  }

  @override
  Future<int> setAudioFocus(TauPlayerCallback callback, {AudioFocus? focus, SessionCategory? category, SessionMode? mode, int? audioFlags, AudioDevice? device,} )
  {
    return invokeMethod( callback, 'setAudioFocus', {'focus': focus!.index, 'category': category!.index, 'mode': mode!.index, 'audioFlags': audioFlags, 'device': device!.index ,},);
  }

  @override
  Future<int> closePlayer(TauPlayerCallback callback, )
  {
    return invokeMethod( callback, 'closePlayer',  Map<String, dynamic>(),);
  }

  @override
  Future<int> getPlayerState(TauPlayerCallback callback, )
  {
    return invokeMethod( callback, 'getPlayerState',  Map<String, dynamic>(),);
  }
  @override
  Future<Map<String, Duration>> getProgress(TauPlayerCallback callback, ) async
  {
    Map<String, int> m = (await invokeMethod( callback, 'getPlayerState', Map<String, dynamic>(),) as Map) as Map<String, int>;
    Map<String, Duration> r = {'duration': Duration(milliseconds: m['duration']!), 'progress': Duration(milliseconds: m['progress']!),};
    return r;
  }

  @override
  Future<bool> isDecoderSupported(TauPlayerCallback callback, { Codec codec = Codec.defaultCodec,})
  {
    return invokeMethodBool( callback, 'isDecoderSupported', {'codec': codec.index,},) as Future<bool>;
  }


  @override
  Future<int> setSubscriptionDuration(TauPlayerCallback callback, { Duration? duration,})
  {
    return invokeMethod( callback, 'setSubscriptionDuration', {'duration': duration!.inMilliseconds},);
  }

  @override
  Future<int> startPlayer(TauPlayerCallback callback,  {Codec? codec, Uint8List? fromDataBuffer, String?  fromURI, int? numChannels, int? sampleRate})
  {
     return  invokeMethod( callback, 'startPlayer', {'codec': codec!.index, 'fromDataBuffer': fromDataBuffer, 'fromURI': fromURI, 'numChannels': numChannels, 'sampleRate': sampleRate},) ;
  }

  @override
  Future<int> startPlayerFromMic(TauPlayerCallback callback, {int? numChannels, int? sampleRate})
  {
    return  invokeMethod( callback, 'startPlayerFromMic', { 'numChannels': numChannels, 'sampleRate': sampleRate, },) ;
  }


  @override
  Future<int> feed(TauPlayerCallback callback, {Uint8List? data, })
  {
    return invokeMethod( callback, 'feed', {'data': data, },) ;
  }

  @override
  Future<int> startPlayerFromTrack(TauPlayerCallback callback, {Duration? progress, Duration? duration, Map<String, dynamic>? track, bool? canPause, bool? canSkipForward, bool? canSkipBackward, bool? defaultPauseResume, bool? removeUIWhenStopped })
  {
    return invokeMethod( callback, 'startPlayerFromTrack', {'progress': (progress != null) ? progress.inMilliseconds : 0, 'duration': (duration != null) ? duration.inMilliseconds : 0,
            'track': track, 'canPause': canPause, 'canSkipForward': canSkipForward, 'canSkipBackward': canSkipBackward,
           'defaultPauseResume': defaultPauseResume, 'removeUIWhenStopped': removeUIWhenStopped,},);
  }

  @override
  Future<int> nowPlaying(TauPlayerCallback callback,  {Duration? progress, Duration? duration, Map<String, dynamic>? track, bool? canPause, bool? canSkipForward, bool? canSkipBackward, bool? defaultPauseResume, }) async
  {
    return invokeMethod( callback, 'nowPlaying', {'progress': progress!.inMilliseconds, 'duration': duration!.inMilliseconds, 'track': track, 'canPause': canPause, 'canSkipForward': canSkipForward, 'canSkipBackward': canSkipBackward,
      'defaultPauseResume': defaultPauseResume,},);
  }

  @override
  Future<int> stopPlayer(TauPlayerCallback callback,  )
  {
    return invokeMethod( callback, 'stopPlayer',  Map<String, dynamic>(),) ;
  }

  @override
  Future<int> pausePlayer(TauPlayerCallback callback,  )
  {
    return invokeMethod( callback, 'pausePlayer',  Map<String, dynamic>(),) ;
  }

  @override
  Future<int> resumePlayer(TauPlayerCallback callback,  )
  {
    return invokeMethod( callback, 'resumePlayer',  Map<String, dynamic>(),) ;
  }

  @override
  Future<int> seekToPlayer(TauPlayerCallback callback,  {Duration? duration})
  {
    return invokeMethod( callback, 'seekToPlayer', {'duration': duration!.inMilliseconds,},) ;
  }

  @override
  Future<int> setVolume(TauPlayerCallback callback,  {double? volume})
  {
    return invokeMethod( callback, 'setVolume', {'volume': volume,}) ;
  }

  @override
  Future<int> setSpeed(TauPlayerCallback callback,  {required double speed})
  {
    return invokeMethod( callback, 'setSpeed', {'speed': speed,}) ;
  }

  @override
  Future<int> setUIProgressBar(TauPlayerCallback callback, {Duration? duration, Duration? progress,})
  {
    return invokeMethod( callback, 'setUIProgressBar', {'duration': duration!.inMilliseconds, 'progress': progress!.inMilliseconds,}) ;

  }

  Future<String> getResourcePath(TauPlayerCallback callback, )
  {
    return invokeMethodString( callback, 'getResourcePath',  Map<String, dynamic>(),) ;
  }

}