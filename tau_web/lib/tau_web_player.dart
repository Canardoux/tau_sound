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

@JS()
library flutter_sound;

import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data' show Uint8List;

import 'package:meta/meta.dart';
import 'package:tau_platform_interface/tau_platform_interface.dart';
import 'package:tau_platform_interface/tau_player_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'dart:io';
import 'package:js/js.dart';
import 'package:logger/logger.dart' show Level , Logger;


// ====================================  JS  =======================================================

@JS('newPlayerInstance')
external TauCorePlayer newPlayerInstance(TauPlayerCallback theCallBack, List<Function> callbackTable);


@JS('TauCorePlayer')
class TauCorePlayer
{
        @JS('TauCorePlayer')
        external factory TauCorePlayer(TauPlayerCallback theCallBack, List<Function> callbackTable);

        @JS('releaseMediaPlayer')
        external int releaseMediaPlayer();

        @JS('initializeMediaPlayer')
        external int initializeMediaPlayer( int focus, int category, int mode, int? audioFlags, int device, bool? withUI);

        @JS('setAudioFocus')
        external int setAudioFocus(int focus, int category, int mode, int? audioFlags, int device,);

        @JS('getPlayerState')
        external int getPlayerState();

        @JS('isDecoderSupported')
        external bool isDecoderSupported( int codec,);

        @JS('setSubscriptionDuration')
        external int setSubscriptionDuration( int duration);

        @JS('startPlayer')
        external int startPlayer(int? codec, Uint8List? fromDataBuffer, String?  fromURI, int? numChannels, int? sampleRate);

        @JS('feed')
        external int feed(Uint8List? data,);

        @JS('startPlayerFromTrack')
        external int startPlayerFromTrack(int progress, int duration, Map<String, dynamic> track, bool canPause, bool canSkipForward, bool canSkipBackward, bool defaultPauseResume, bool removeUIWhenStopped, );

        @JS('nowPlaying')
        external int nowPlaying(int progress, int duration, Map<String, dynamic>? track, bool? canPause, bool? canSkipForward, bool? canSkipBackward, bool? defaultPauseResume, );

        @JS('stopPlayer')
        external int stopPlayer();

        @JS('resumePlayer')
        external int pausePlayer();

        @JS('')
        external int resumePlayer();

        @JS('seekToPlayer')
        external int seekToPlayer( int duration);

        @JS('setVolume')
        external int setVolume(double? volume);

        @JS('setSpeed')
        external int setSpeed(double speed);

        @JS('setUIProgressBar')
        external int setUIProgressBar(int duration, int progress);
}

List<Function> callbackTable =
[
        allowInterop( (TauPlayerCallback cb, int position, int duration)                       { cb.updateProgress(duration: duration, position: position,);} ),
        allowInterop( (TauPlayerCallback cb, int state)                                        { cb.pauseCallback(state,);} ),
        allowInterop( (TauPlayerCallback cb, int state)                                        { cb.resumeCallback(state,);} ),
        allowInterop( (TauPlayerCallback cb, int state)                                        { cb.skipBackward(state,);} ),
        allowInterop( (TauPlayerCallback cb, int state)                                        { cb.skipForward(state,);} ),
        allowInterop( (TauPlayerCallback cb, int state)                                        { cb.updatePlaybackState(state,);} ),
        allowInterop( (TauPlayerCallback cb, int ln)                                           { cb.needSomeFood(ln,);} ),
        allowInterop( (TauPlayerCallback cb, int state)                                        { cb.audioPlayerFinished(state,);} ),
        allowInterop( (TauPlayerCallback cb, int state, bool success, int duration)            { cb.startPlayerCompleted(state, success, duration,);} ),
        allowInterop( (TauPlayerCallback cb, int state, bool success)                          { cb.pausePlayerCompleted(state, success);} ),
        allowInterop( (TauPlayerCallback cb, int state, bool success)                          { cb.resumePlayerCompleted(state, success);} ),
        allowInterop( (TauPlayerCallback cb, int state, bool success)                          { cb.stopPlayerCompleted(state, success);} ),
        allowInterop( (TauPlayerCallback cb, int state, bool success)                          { cb.openPlayerCompleted(state, success);} ),
        allowInterop( (TauPlayerCallback cb, int state, bool success)                          { cb.closePlayerCompleted(state, success);} ),
        allowInterop( (TauPlayerCallback cb,  int level, String msg)                           { cb.log(Level.values[level], msg);} ),
];

//=========================================================================================================


/// The web implementation of [TauPlatform].
///
/// This class implements the `package:flutter_sound_player` functionality for the web.
///

class TauPlayerWeb extends TauPlayerPlatform //implements TauPlayerCallback
{


        static List<String> defaultExtensions  =
        [
                "flutter_sound.aac", // defaultCodec
                "flutter_sound.aac", // aacADTS
                "flutter_sound.opus", // opusOGG
                "flutter_sound_opus.caf", // opusCAF
                "flutter_sound.mp3", // mp3
                "flutter_sound.ogg", // vorbisOGG
                "flutter_sound.pcm", // pcm16
                "flutter_sound.wav", // pcm16WAV
                "flutter_sound.aiff", // pcm16AIFF
                "flutter_sound_pcm.caf", // pcm16CAF
                "flutter_sound.flac", // flac
                "flutter_sound.mp4", // aacMP4
                "flutter_sound.amr", // amrNB
                "flutter_sound.amr", // amrWB
                "flutter_sound.pcm", // pcm8
                "flutter_sound.pcm", // pcmFloat32
        ];



        /// Registers this class as the default instance of [TauPlatform].
        static void registerWith(Registrar registrar)
        {
                TauPlayerPlatform.instance = TauPlayerWeb();
        }


        /* ctor */ MethodChannelTauPlayer()
        {
        }


//============================================ Session manager ===================================================================


        List<TauCorePlayer?> _slots = [];
        TauCorePlayer? getWebSession(TauPlayerCallback callback)
        {
                return _slots[findSession(callback)];
        }



//==============================================================================================================================

        @override
        Future<void>?   resetPlugin(TauPlayerCallback callback,)
        {
                callback.log(Level.debug, '---> resetPlugin');
                for (int i = 0; i < _slots.length; ++i)
                {
                        callback.log(Level.debug, "Releasing slot #$i");
                        _slots[i]!.releaseMediaPlayer();
                }
                _slots = [];
                callback.log(Level.debug, '<--- resetPlugin');
                return null;
        }


        @override
        Future<int> openPlayer(TauPlayerCallback callback, {required Level logLevel, AudioFocus? focus, SessionCategory? category, SessionMode? mode, int? audioFlags, AudioDevice? device, bool? withUI}) async
        {
                // openAudioSessionCompleter = new Completer<bool>();
                // await invokeMethod( callback, 'initializeMediaPlayer', {'focus': focus.index, 'category': category.index, 'mode': mode.index, 'audioFlags': audioFlags, 'device': device.index, 'withUI': withUI ? 1 : 0 ,},) ;
                // return  openAudioSessionCompleter.future ;
                int slotno = findSession(callback);
                TauCorePlayer player = newPlayerInstance(callback, callbackTable);// TauCorePlayer(callback, callbackTable);
                if (slotno < _slots.length)
                {
                        assert (_slots[slotno] == null);
                        _slots[slotno] = player;
                } else
                {
                        assert(slotno == _slots.length);
                        _slots.add( player);
                }

                return _slots[slotno]!.initializeMediaPlayer( focus!.index,  category!.index, mode!.index, audioFlags, device!.index, withUI);
        }


        @override
        Future<int> closePlayer(TauPlayerCallback callback, ) async
        {
                int slotno = findSession(callback);
                int r = _slots[slotno]!.releaseMediaPlayer();
                _slots[slotno] = null;
                return r;
        }



        @override
        Future<int> setAudioFocus(TauPlayerCallback callback, {AudioFocus? focus, SessionCategory? category, SessionMode? mode, int? audioFlags, AudioDevice? device,} ) async
        {
                return getWebSession(callback)!.setAudioFocus(focus!.index, category!.index, mode!.index, audioFlags, device!.index);
        }


        @override
        Future<int> getPlayerState(TauPlayerCallback callback, ) async
        {
                return getWebSession(callback)!.getPlayerState();
        }


        @override
        Future<Map<String, Duration>> getProgress(TauPlayerCallback callback, ) async
        {
                // Map<String, int> m = await invokeMethod( callback, 'getPlayerState', null,) as Map;
                Map<String, Duration> r = {'duration': Duration.zero, 'progress': Duration.zero,};
                return r;
        }

        @override
        Future<bool> isDecoderSupported(TauPlayerCallback callback, { required Codec codec ,}) async
        {
                return getWebSession(callback)!.isDecoderSupported(codec.index);
        }


        @override
        Future<int> setSubscriptionDuration(TauPlayerCallback callback, { Duration? duration,}) async
        {
                return getWebSession(callback)!.setSubscriptionDuration(duration!.inMilliseconds);
        }

        @override
        Future<int> startPlayer(TauPlayerCallback callback,  {Codec? codec, Uint8List? fromDataBuffer, String?  fromURI, int? numChannels, int? sampleRate}) async
        {
                // startPlayerCompleter = new Completer<Map>();
                // await invokeMethod( callback, 'startPlayer', {'codec': codec.index, 'fromDataBuffer': fromDataBuffer, 'fromURI': fromURI, 'numChannels': numChannels, 'sampleRate': sampleRate},) ;
                // return  startPlayerCompleter.future ;
                // String s = "https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_700KB.mp3";
                if (codec == null)
                        codec = Codec.defaultCodec;
                if (fromDataBuffer != null)
                {
                        if (fromURI != null)
                        {
                                throw Exception("You may not specify both 'fromURI' and 'fromDataBuffer' parameters");
                        }
                        //js.context.callMethod('playAudioFromBuffer', [fromDataBuffer]);
                        //playAudioFromBuffer(fromDataBuffer);
                        // .......................return getWebSession(callback).playAudioFromBuffer(fromDataBuffer);
                        //playAudioFromBuffer3(fromDataBuffer);
                        //Directory tempDir = await getTemporaryDirectory();
                        /*
                        String path = defaultExtensions[codec.index];
                        File filOut = File(path);
                        IOSink sink = filOut.openWrite();
                        sink.add(fromDataBuffer.toList());
                        fromURI = path;
                         */
                }
                //js.context.callMethod('playAudioFromURL', [fromURI]);
                callback.log(Level.debug, 'startPlayer FromURI : $fromURI');
                return getWebSession(callback)!.startPlayer(codec.index,  fromDataBuffer, fromURI, numChannels, sampleRate);
        }


        @override
        Future<int> startPlayerFromMic(TauPlayerCallback callback, {int? numChannels, int? sampleRate}) {
                throw Exception('StartPlayerFromMic() is not implemented on Flutter Web');
        }

                @override
        Future<int> feed(TauPlayerCallback callback, {Uint8List? data, }) async
        {
                return getWebSession(callback)!.feed(data);
        }

        @override
        Future<int> startPlayerFromTrack(TauPlayerCallback callback, { Duration? progress, Duration? duration, Map<String, dynamic>? track, bool? canPause, bool? canSkipForward, bool? canSkipBackward, bool? defaultPauseResume, bool? removeUIWhenStopped }) async
        {
                // startPlayerCompleter = new Completer<Map>();
                // await invokeMethod( callback, 'startPlayerFromTrack', {'progress': progress, 'duration': duration, 'track': track, 'canPause': canPause, 'canSkipForward': canSkipForward, 'canSkipBackward': canSkipBackward,
                //   'defaultPauseResume': defaultPauseResume, 'removeUIWhenStopped': removeUIWhenStopped,},);
                // return  startPlayerCompleter.future ;
                //
                //return getWebSession(callback).startPlayerFromTrack( progress.inMilliseconds,  duration.inMilliseconds, track, canPause, canSkipForward, canSkipBackward, defaultPauseResume, removeUIWhenStopped);
                return getWebSession(callback)!.startPlayer(track!['codec'],  track['dataBuffer'], track['path'], track['numChannels'], track['sampleRate']);
          }

        @override
        Future<int> nowPlaying(TauPlayerCallback callback,  {Duration? progress, Duration? duration,  Map<String, dynamic>? track, bool? canPause, bool? canSkipForward, bool? canSkipBackward, bool? defaultPauseResume, }) async
        {
                return getWebSession(callback)!.nowPlaying(progress!.inMilliseconds, duration!.inMilliseconds, track, canPause, canSkipForward, canSkipBackward, defaultPauseResume);
        }

        @override
        Future<int> stopPlayer(TauPlayerCallback callback,  ) async
        {
                return getWebSession(callback)!.stopPlayer();
        }

        @override
        Future<int> pausePlayer(TauPlayerCallback callback,  ) async
        {
                return getWebSession(callback)!.pausePlayer();
        }

        @override
        Future<int> resumePlayer(TauPlayerCallback callback,  ) async
        {
                return getWebSession(callback)!.resumePlayer();
        }

        @override
        Future<int> seekToPlayer(TauPlayerCallback callback,  {Duration? duration}) async
        {
                return getWebSession(callback)!.seekToPlayer(duration!.inMilliseconds);
        }

        Future<int> setVolume(TauPlayerCallback callback,  {double? volume}) async
        {
                return getWebSession(callback)!.setVolume(volume);
        }

        Future<int> setSpeed(TauPlayerCallback callback,  {required double speed}) async
        {
                return getWebSession(callback)!.setSpeed(speed);
        }

        @override
        Future<int> setUIProgressBar(TauPlayerCallback callback, {Duration? duration, Duration? progress,}) async
        {
                return getWebSession(callback)!.setUIProgressBar(duration!.inMilliseconds, progress!.inMilliseconds);
        }

        Future<String> getResourcePath(TauPlayerCallback callback, ) async
        {
                return '';
        }

        @override
        Future<void>?   setLogLeve(TauPlayerCallback callback, Level loglevel)
        {

        }

 }
