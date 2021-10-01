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

import 'package:meta/meta.dart';
import 'package:tau_platform_interface/tau_platform_interface.dart';
import 'package:tau_platform_interface/tau_recorder_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'dart:typed_data';
import 'package:logger/logger.dart' show Level , Logger;

import 'package:js/js.dart';

//========================================  JS  ===============================================================

@JS('newRecorderInstance')
external TauRecorder newRecorderInstance(TauRecorderCallback callBack, List<Function> callbackTable);

@JS('TauRecorder')
class TauRecorder
{
        @JS('newInstance')
        external static TauRecorder newInstance(TauRecorderCallback callBack, List<Function> callbackTable);

        @JS('initializeFlautoRecorder')
        external void initializeFlautoRecorder( int focus, int category, int mode, int? audioFlags, int device);

        @JS('releaseFlautoRecorder')
        external void releaseFlautoRecorder();

        @JS('setAudioFocus')
        external void setAudioFocus(int focus, int category, int mode, int? audioFlags, int device);

        @JS('isEncoderSupported')
        external bool isEncoderSupported(int codec);

        @JS('setSubscriptionDuration')
        external void setSubscriptionDuration(int duration);

        @JS('startRecorder')
        external void startRecorder(String? path, int? sampleRate, int? numChannels, int? bitRate, int codec, bool? toStream, int audioSource);

        @JS('stopRecorder')
        external void stopRecorder();

        @JS('pauseRecorder')
        external void pauseRecorder();

        @JS('resumeRecorder')
        external void resumeRecorder();

        @JS('getRecordURL')
        external String getRecordURL(String path,);

        @JS('deleteRecord')
        external bool deleteRecord(String path,);

}


List<Function> callbackTable =
[
        allowInterop( (TauRecorderCallback cb,  int duration, double dbPeakLevel)               { cb.updateRecorderProgress(duration: duration, dbPeakLevel: dbPeakLevel);} ),
        allowInterop( (TauRecorderCallback cb, {Uint8List? data})                               { cb.recordingData(data: data);} ),
        allowInterop( (TauRecorderCallback cb,  int state, bool success)                        { cb.startRecorderCompleted(state, success);} ),
        allowInterop( (TauRecorderCallback cb,  int state, bool success)                        { cb.pauseRecorderCompleted(state, success);} ),
        allowInterop( (TauRecorderCallback cb,  int state, bool success)                        { cb.resumeRecorderCompleted(state, success);} ),
        allowInterop( (TauRecorderCallback cb,  int state, bool success, String url)            { cb.stopRecorderCompleted(state, success, url);} ),
        allowInterop( (TauRecorderCallback cb,  int state, bool success)                        { cb.openRecorderCompleted(state, success);} ),
        allowInterop( (TauRecorderCallback cb,  int state, bool success)                        { cb.closeRecorderCompleted(state, success);} ),
        allowInterop( (TauRecorderCallback cb,  int level, String msg)                          { cb.log(Level.values[level], msg);} ),
];


//============================================================================================================================

/// The web implementation of [TauRecorderPlatform].
///
/// This class implements the `package:TauPlayerPlatform` functionality for the web.
class TauRecorderWeb extends TauRecorderPlatform //implements TauRecorderCallback
{

        /// Registers this class as the default instance of [TauRecorderPlatform].
        static void registerWith(Registrar registrar)
        {
                TauRecorderPlatform.instance = TauRecorderWeb();
        }




        List<TauRecorder?> _slots = [];
        TauRecorder? getWebSession(TauRecorderCallback callback)
        {
                return _slots[findSession(callback)];
        }


//================================================================================================================

        @override
        Future<void>?   resetPlugin(TauRecorderCallback callback,) async
        {
                callback.log(Level.debug, '---> resetPlugin');
                for (int i = 0; i < _slots.length; ++i)
                {
                        callback.log(Level.debug, "Releasing slot #$i");
                        _slots[i]!.releaseFlautoRecorder();
                }
                _slots = [];
                callback.log(Level.debug, '<--- resetPlugin');
                return null;
        }

        @override
        Future<void> openRecorder(TauRecorderCallback callback, {required Level logLevel, AudioFocus? focus, SessionCategory? category, SessionMode? mode, int? audioFlags, AudioDevice? device}) async
        {
                int slotno = findSession(callback);
                if (slotno < _slots.length)
                {
                        assert (_slots[slotno] == null);
                        _slots[slotno] = newRecorderInstance(callback, callbackTable);
                } else
                {
                        assert(slotno == _slots.length);
                        _slots.add( newRecorderInstance(callback, callbackTable));
                }

                _slots[slotno]!.initializeFlautoRecorder(focus!.index, category!.index, mode!.index, audioFlags, device!.index);
        }


        @override
        Future<void> closeRecorder(TauRecorderCallback callback, ) async
        {
                int slotno = findSession(callback);
                _slots[slotno]!.releaseFlautoRecorder();
                _slots[slotno] = null;
        }

        @override
        Future<void> setAudioFocus(TauRecorderCallback callback, {AudioFocus? focus, SessionCategory? category, SessionMode? mode, int? audioFlags, AudioDevice? device,} ) async
        {
                getWebSession(callback)!.setAudioFocus(focus!.index, category!.index, mode!.index, audioFlags, device!.index);
        }

        @override
        Future<bool> isEncoderSupported(TauRecorderCallback callback, {required Codec codec,}) async
        {
                return getWebSession(callback)!.isEncoderSupported(codec.index);
        }

        @override
        Future<void> setSubscriptionDuration(TauRecorderCallback callback, {Duration? duration,}) async
        {
                getWebSession(callback)!.setSubscriptionDuration(duration!.inMilliseconds);
        }

        @override
        Future<void> startRecorder(TauRecorderCallback callback,
            {
                    String? path,
                    int? sampleRate,
                    int? numChannels,
                    int? bitRate,
                    Codec? codec,
                    bool? toStream,
                    AudioSource? audioSource,
            }) async
        {
                getWebSession(callback)!.startRecorder(path, sampleRate, numChannels, bitRate, codec!.index, toStream, audioSource!.index,);
        }

        @override
        Future<void> stopRecorder(TauRecorderCallback callback,  ) async
        {
                TauRecorder? session = getWebSession(callback);
                if (session != null)
                        session.stopRecorder();
                else
                        callback.log(Level.debug, 'Recorder already stopped');
        }

        @override
        Future<void> pauseRecorder(TauRecorderCallback callback,  ) async
        {
                getWebSession(callback)!.pauseRecorder();
        }

        @override
        Future<void> resumeRecorder(TauRecorderCallback callback, ) async
        {
                getWebSession(callback)!.resumeRecorder();
        }

        @override
        Future<String> getRecordURL (TauRecorderCallback callback, String path ) async
        {
                return  getWebSession(callback)!.getRecordURL(path);
        }

        @override
        Future<bool> deleteRecord (TauRecorderCallback callback, String path ) async
        {
                return getWebSession(callback)!.deleteRecord(path);
        }

}
